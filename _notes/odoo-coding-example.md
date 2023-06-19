---
layout: note
draft: false
date: 2022-05-06 08:56:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

## Sort by a field with a other field in an Odoo tree view

The Odoo model has the following fields:

- name: Char field representing the name of the file.
- size: Float field representing the size of the file.
- size_human: Char field used to display the human-readable size of the file. It is computed using the `_compute_size_for_human` method.

The `_compute_size_for_human` method takes each record of the File model and calculates the human-readable size using the `_sizeof_fmt` function. The `_sizeof_fmt` function converts the file size in bytes to a more readable format (e.g., KB, MB, GB, etc.).

The `_generate_order_by` method is overridden to modify the sorting behavior of the model's queries. If the sorting is based on the size_human field, it replaces it with the size field in the order specification. This change allows for number sorting based on the file size rather than sorting based on the human-readable size.

```py
class File(models.Model):
    _name = 'example.file'
    _description = 'Example File'

    name = fields.Char(string='Name', required=True)
    size = fields.Float(string='Size', size=20, digits=(20, 0), required=True)
    size_human = fields.Char(string='Size', compute='_compute_size_for_human', store=True)

    def _generate_order_by(self, order_spec, query):
        """
        Generate the ORDER BY clause for file queries. If the order is on the size human field
        replace it by the size field to perform a number sorting.
        """
        if order_spec and 'size_human' in order_spec:
            order_spec = order_spec.replace('size_human', 'size')
        return super(File, self)._generate_order_by(order_spec, query)

    @api.depends('size')
    def _compute_size_for_human(self):
        """
        Compute size human
        """
        for file in self:
            file.size_human = _sizeof_fmt(file.size)
```