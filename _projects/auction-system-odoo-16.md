---
layout: project
title: Implementing an Auction System in Odoo 16.0
draft: true
active: false
date: 2025-07-16 00:00:00 +0200
author: Victor Hachard
languages:
    - Odoo
    - Python
    - JavaScript
    - XML
---

## 1. Introduction

Explore how to extend Odoo 16.0 to support online auctions with manual bids, automatic (max-bid) bids, real-time updates, and automatic sale order creation. We’ll cover:

* **Model extensions**: New fields, state machine, bidding logic, cron jobs
* **HTTP controllers**: Routes for bid submission, auto-bid management, page rendering
* **JavaScript client**: WebSocket-based real-time updates via the `bus.bus` service
* **Workflow**: From auction creation to order generation

## 2. Workflow Summary

1. **Setup**:
    
    L’**Admin** crée un enregistrement d’enchère avec un état initial **draft**, en définissant les dates, les règles d’incrémentation et les prix (initial et de réserve). Il confirme ensuite l’enchère, ce qui la fait passer à l’état **confirmed**.

2. **Start**:

   Lorsqu’un **User** visite la page produit, ou à l’aide d’un cron, le backend exécute `set_auction_state()` en fonction des dates. Cela active l’enchère (état **running**), ou la clôture si expirée.

3. **Bidding**:

   * Les utilisateurs peuvent soumettre une enchère manuelle via `/auction/bid`, ou fixer un plafond d’enchère automatique via `/auction/auto_bid/set`.
   * Le backend valide les enchères, exécute `execute_auto_bidding`, puis met à jour le `website_hash` pour déclencher une notification.

4. **Notifications (temps réel)**:

   * Tous les clients connectés (y compris d'autres visiteurs de la page produit) abonnés au canal WebSocket `auction_updates` reçoivent une notification via `bus.bus`.
   * Le client JS appelle `/auction/sync`, récupère le HTML mis à jour, remplace dynamiquement le contenu de la page et relance le compte à rebours si nécessaire.

5. **End & Order**:

   À la **date de fin** (ou après prolongation), `set_auction_state()` passe l’enchère à l’état **complete** ou **closed**. Si le prix de réserve est atteint, l’**Admin** déclenche `action_finish_auction()`, générant automatiquement une **commande de vente (sale.order)** pour le gagnant.

<div style="overflow-x: scroll;">
<pre class="mermaid" style="width: 150%;">
sequenceDiagram
    participant Admin
    participant User
    participant OtherClient
    participant Website
    participant Backend
    participant JS_Client

    Admin->>Backend: Create Auction
    Backend-->>Admin: Auction saved
    Admin->>Backend: Confirm Auction
    Backend-->>Admin: Auction confirmed

    User->>Website: Visit Product Page
    Website->>Backend: Call set_auction_state()
    Backend-->>Website: Updated auction (maybe running or ended)

    User->>JS_Client: Load product page with auction_id
    JS_Client->>Backend: Subscribe to auction_updates

    User->>Backend: /auction/bid or /auction/auto_bid/set (manual)
    Backend->>Backend: Validate bid or auto_bid + trigger auto-bid
    Backend-->>JS_Client: Push website_hash via bus.bus
    Backend-->>OtherClient: Push website_hash via bus.bus
    JS_Client->>Backend: /auction/sync
    Backend-->>JS_Client: Return updated HTML
    JS_Client-->>User: Replace updated HTML
</pre>
</div>

## 3. Extending the Backend Model

We create a new model `website.auction`:

```python
class WebsiteAuction(models.Model):
    _name = "website.auction"
    _description = 'Website Auction'
    _order = 'name desc'

    # States: draft → confirmed → running → complete → order_created
    state = fields.Selection([...], default='draft')
    initial_price = fields.Float(required=True)
    reserve_price = fields.Float(required=True)
    start_date = fields.Datetime(required=True)
    end_date = fields.Datetime(required=True)

    # Current bid, winner/losers, bidders, auto-bidders…
    current_price = fields.Float(compute='_get_current_winner', store=True)
    winner_id = fields.Many2one('res.partner', compute='_get_current_winner', store=True)
    bidder_ids = fields.One2many('auction.bidder', 'auction_fk')
    auto_bidder_ids = fields.One2many('auction.auto.bidder', 'auction_fk')
    reserve_price_meet = fields.Boolean(compute='_compute_reserve_price_meet', store=True)
```

Key points:

1. **State Machine & Cron**

   * A `set_auction_state` method (called by a cron or on page load) moves auctions through states based on `start_date`, `end_date` (and optional extension).

2. **Bidding Logic**

   * `create_bid` validates manual bids (state, min/max, anti-sniping, repeat bids), writes to `auction.bidder`, and triggers `execute_auto_bidding`.

3. **Auto-Bidding**

   * Users set a maximum bid via `auction.auto.bidder`.
   * `execute_auto_bidding` loops, pitting auto-bidders against each other by always bidding “one increment above the second-highest max,” without exceeding your own max.

When an auction ends with reserve met, it transitions to **complete**, and `action_finish_auction` creates a `sale.order` for the winning partner.

## 4. HTTP Controllers

We extend Odoo’s `website_sale` controller to inject auction logic into product pages and provide JSON endpoints:

```python
class WebsiteSale(website_sale):

    @http.route(['/auction/sync'], type='json', auth="public", website=True, csrf=False)
    def auction_sync(self, **post):
        auction = request.env['website.auction'].sudo().browse(int(post['auction_id']))
        auction.set_auction_state()
        if post.get('website_hash') != auction.website_hash:
            return {'html': self._render_website_product(auction)}
        return {}
```

* **Page Rendering**
  * Overrides the normal product route to search for an active auction and call `set_auction_state()` before rendering.

* **Bid Endpoints**
  * `/auction/bid` for manual bids, catching exceptions (`MinimumBidException`, etc.) and returning an HTML snippet plus a status code.
  * `/auction/auto_bid/set` and `/auction/auto_bid/remove` for managing max-bids similarly.

## 5. Real-Time Client with WebSockets

On the front end, we register a service that listens to Odoo’s `bus_service` on channel `auction_updates`:

```js
import { registry } from "@web/core/registry";

export const websiteSaleWs = {
  start(env, { bus_service, rpc, dialog }) {
    // Only on product pages with data-auction_id
    this.auction_id = parseInt(...);
    this.busService = bus_service;
    this.busService.addChannel('auction_updates');
    this.busService.addEventListener('notification', this.onMessage.bind(this));
    this.busService.start();
    this.renderCountdown();
    this.attachAllButtonListeners();
  },

  async onMessage({ detail: notifications }) {
    for (const note of notifications) {
      if (note.payload.auction_id === this.auction_id &&
          note.payload.website_hash !== currentHash) {
        await this.refresh();
      }
    }
  },

  async refresh() {
    const result = await this.rpc('/auction/sync', {
      auction_id: this.auction_id,
      website_hash: currentHash,
    });
    if (result.html) {
      document.querySelector('#js_replace_me_please').innerHTML = result.html;
      this.renderCountdown();
      this.attachAllButtonListeners();
    }
  },
  // …plus methods to attach click handlers for bid, auto-bid, subscribe, etc.
};
registry.category("services").add("websiteSaleWs", websiteSaleWs);
```

* **WebSocket Notifications**
  * Each time the Python model’s `website_hash` changes (in `_compute_website_hash`), it calls `bus.bus._sendone('auction_updates', …)`.
  * The JS client detects changes and re-RPCs `/auction/sync` to pull fresh HTML.

* **Countdown Timer**
  * We use a small jQuery plugin to render time left; once expired, the server side will have moved the auction to “complete” or “closed.”
