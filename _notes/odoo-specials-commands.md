---
title: Odoo specials commands for creating records in relation
layout: note
draft: false
date: 2022-03-04 14:42:00 +0200
author: Victor Hachard
---

## List of commands

This commands allows to assign a value/s to One2many or Many2many

-   `(0, 0, { values })` adds a new record (write *values* on it)
-   `(1, ID, { values })` update the linked record with id = ID (write *values* on it), can not be used in ~.create.
-   `(2, ID)` remove and delete the linked record with id = ID (calls unlink on ID, that will delete the object completely, and the link to it as well), can not be used in ~.create.
-   `(3, ID)` cut the link to the linked record with id = ID (delete the relationship between the two objects but does not delete the target object itself), can not be used in ~.create.
-   `(4, ID)` link to existing record with id = ID (adds a relationship), can not be used on ~odoo.fields.One2many.
-   `(5) ` unlink all (like using (3,ID) for all linked records), can not be used on ~odoo.fields.One2many and can not be used in ~.create.
-   `(6, 0, [IDs])` replace the list of linked IDs (like using (5) then (4,ID) for each ID in the list of IDs), can not be used on ~odoo.fields.One2many.

### Examples

```py
rule_1.write({
    'auto_reconcile': True,
    'line_ids': [
        (1, rule_1.line_ids.id, {
            'amount': 50,
            'tax_ids': [(6, 0, tax21.ids)],
        }),
        (0, 0, {
            'amount': 100,
            'tax_ids': [(6, 0, tax12.ids)],
        })
    ]
})
```
