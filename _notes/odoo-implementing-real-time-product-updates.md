---
layout: note
title: Odoo 16.0 Implementing Real-Time Product Updates
draft: false
date: 2024-06-12 21:42:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

## Purpose

The goal is to refresh product information dynamically when there are changes.

## Implementation

<pre class="mermaid">
sequenceDiagram
    autonumber
    participant DB as Odoo Backend
    participant WS as WebSocket (bus.bus)
    participant PY as Python Controller
    participant JS as JavaScript (Frontend)
    participant HTML as Website UI
    
    DB->>WS: Notify WebSocket on Product Update
    WS->>JS: Send Notification with Product ID
    JS->>PY: Call /product/tree/sync with Product ID
    PY->>DB: Fetch Updated Product Data
    DB->>PY: Return Product Data
    PY->>JS: Send Rendered HTML
    JS->>HTML: Replace Product Section in DOM
</pre>

### 1. Python Controller Backend

#### Render Website Products

This method is responsible for rendering the product information using the specified template.

```python
def _render_website_products(self, product_obj):
    html_return = request.env["ir.ui.view"]._render_template(
        'website_sale.inherited_products_description_website_sale2', {
            'website': request.env['website'].browse(1),
            'product': product_obj,
        }
    )
    return {
        'html': html_return,
    }
```

#### Product Sync Endpoint

This method is exposed as a public route to allow the JavaScript code to request updated product information.

```python
@http.route(['/product/tree/sync'], type='json', auth="public", website=True, csrf=False)
def product_tree_sync(self, product_id):
    product_obj = request.env['product.template'].sudo().browse(int(product_id))
    return self._render_website_products(product_obj)
```

### 2. Python Backend

This method sends a notification to the WebSocket service when there is an update in the product status.

```python
def notify_websocket(self):
    self.ensure_one()
    self.env['bus.bus']._sendone('product_updates', 'notification', {
        'product_tmpl_id': self.product_tmpl_id.id,
    })
```

### 3. JavaScript Frontend

Define a JavaScript module to handle WebSocket connections and update the DOM when there are notifications.

```javascript
/** @odoo-module */

import { registry } from "@web/core/registry";
import websiteSaleList from "website_sale.website_sale_list";

export const websiteSaleTreeWs = {
    dependencies: ['bus_service', 'rpc'],

    start(env, { bus_service, rpc }) {
        if (!document.querySelector('.oe_website_sale') || !document.querySelector('.oe_product_cart')) {
            return;
        }
        this.product_ids = Array.from(document.querySelectorAll('div[data-product_id]')).map(product => parseInt(product.getAttribute('data-product_id')));

        this.rpc = rpc;

        this.busService = bus_service;
        this.busService.addChannel('product_updates');
        this.busService.addEventListener('notification', this.onMessage.bind(this));
        this.busService.start();
    },
    destroy() {
        this.busService.removeEventListener('notification', this.onMessage.bind(this));
        this.busService.stop();
    },
    async onMessage({ detail: notifications }) {
        for (const notification of notifications) {
            if (this.product_ids.includes(notification['payload']['product_tmpl_id'])) {
                const result = await this.rpc('/product/tree/sync', {
                    product_id: notification['payload']['product_tmpl_id'],
                });
                if (result) {
                    let product = document.querySelector(`.oe_product_cart[data-product_id="${notification['payload']['product_tmpl_id']}"]`);
                    product = product && product.querySelector('.js_replace_me_please');
                    if (product) {
                        product.parentElement.innerHTML = result.html;
                    }
                }
            }
        }
    }
}

registry.category("services").add("websiteSaleTreeWs", websiteSaleTreeWs);
```

### 4. XML Templates

#### Product Description Template

This template contains the structure for rendering product information.

```xml
<template id="inherited_products_description_website_sale2" name="Website Sale Products 2">
    <div> <!-- this div is important for js replacement -->
        <div class="js_replace_me_please">
            <div>
                <h6>
                    <a t-field="product.name"/>
                </h6>
            </div>
        </div>
    </div>
</template>
```

#### Inherited Product Template

This template extends the existing product template to include data attributes.

```xml
<template id="inherited_products_description_website_sale" name="Website Sale Products" inherit_id="website_sale.products_item">
    <xpath expr="//form" position="replace">
        <div t-att-data-product_id="product.id">
            <t t-call="website_sale.inherited_products_description_website_sale2"/>
        </div>
    </xpath>
</template>
```
