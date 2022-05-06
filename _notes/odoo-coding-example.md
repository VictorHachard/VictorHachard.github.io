---
layout: note
draft: false
date: 2022-05-06 08:56:00 +0200
author: Victor Hachard
---

## In Odoo tree view sort by a field with a other field

```py
def _sizeof_fmt(num, suffix="B"):
    """
    Return the human readable size of a file. The default suffix is in bytes.
    """
    for unit in ["", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"]:
        if abs(num) < 1024.0:
            return f"{num:3.1f}{unit}{suffix}"
        num /= 1024.0
    return f"{num:.1f}Yi{suffix}"


class File(models.Model):
    _name = 'example.file'
    _description = 'Example File'

    name = fields.Char(string='Name', required=True, readonly=True)
    size = fields.Float(string='Size', size=20, digits=(20, 0), required=True, readonly=True)
    size_human = fields.Char(string='Size', compute='_compute_size_for_human', readonly=True)

    def _generate_order_by(self, order_spec, query):
        """
        Generate the ORDER BY clause for file queries. If the order is on the size human field
        replace it by the size field to perform a number sorting.
        """
        if order_spec and 'size_human' in order_spec:
            order_spec = order_spec.replace('size_human', 'size')
        return super(File, self)._generate_order_by(order_spec, query)

    def _compute_size_for_human(self):
        """
        Compute size human
        """
        for file in self:
            file.size_human = _sizeof_fmt(file.size)
```