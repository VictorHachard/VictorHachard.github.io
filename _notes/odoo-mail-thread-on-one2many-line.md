---
layout: note
title: Odoo Mail Thread on One2many Line
draft: false
date: 2023-09-21 09:55:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

To have one2many line tracking value in the parent model, you need to inherit the `mail.thread` model in parent model and the child model and override the `_mail_track` method in the child model.

```py
class Sale(models.Model):
    _name = 'sale'
    _inherit = ['mail.thread']

    line_ids = fields.One2many('sale.line', 'sale_id', string='Lines')
```

```py
class SaleLine(models.Model):
    _name = 'sale.line'
    _inherit = ['mail.thread']

    sale_id = fields.Many2one('sale', string='Sale')

    def _mail_track(self, tracked_fields, initial):
        changes, tracking_value_ids = super()._mail_track(tracked_fields, initial)
        if changes:
            self.sale_id._message_log(
                body='Line: <b>%s</b>' % self.name,
                tracking_value_ids=tracking_value_ids
            )
        return changes, tracking_value_ids
```
