---
layout: note
title: Odoo Get Translated Selection Values in Odoo
draft: false
date: 2023-06-14 14:44:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

Retrieve translated selection values in Odoo by utilizing the `fields_get` function. The provided code snippet demonstrates how to display the translated labels of a selection field in the generated display names of records.

```py
invoice_recurrence = fields.Selection([('months', 'Monthly'), ('years', 'Yearly')], required=True,
                                          string='Invoice Recurrence')

def name_get(self):
    res = []

    invoice_recurrence_dict = dict(self.fields_get(allfields=['invoice_recurrence'])['invoice_recurrence']['selection'])
    for record in self:
        res.append((record.id, f"{_(invoice_recurrence_dict[record.invoice_recurrence])}"))
    return res
```
