---
layout: note
draft: false
date: 2022-03-04 14:42:00 +0200
author: Victor Hachard
---

## Model Methode

When working with models, you often need to modify records. Odoo provides several methods to achieve this, including create, unlink, write and update.

## Create

`self.unlink(vals)`: This method is used to create new records in the database. It takes a dictionary vals as an argument, where the keys are the fields of the new record, and the values are the values for those fields. The create method returns the newly created record.

```py
def create_new_product(self, name, price):
    product = self.env['product.product'].create({'name': name, 'list_price': price})
    return product
```

### Unlink

`self.unlink()`: This method is used to delete records from the database. It removes the record associated with the current instance of the model. The unlink method returns True if the deletion is successful.

```py
def delete_product(self, product_id):
    product = self.env['product.product'].browse(product_id)
    product.unlink()
```

### Write

`self.write(vals)`: This method is used to update existing records in the database. It takes a dictionary vals as an argument, where the keys are the fields to be updated, and the values are the new values for those fields. The write method returns True if the update is successful.

```py
def update_product_price(self, product_id, new_price):
    product = self.env['product.product'].browse(product_id)
    product.write({'list_price': new_price})
```


### Update

`self.update(vals)`: This method is used to update multiple records in a single call. It takes a dictionary vals as an argument, similar to self.write(), but it updates all the records that match a certain domain. The update method returns the number of records updated.

```py
def update_product_price(self, product_id, new_price):
     product = self.env['product.product'].browse(product_id)
    products.update({'list_price': new_price})
```

### Key differences between the update and write methods

| | Write | Update |
| --- | --- | --- |
| Usage | Used to update existing record(s) in the database. | Used to update a record. |
| Calling | Syntax: self.write(vals) | Syntax: self.update(vals) |
| Arguments <td colspan=2> Takes a dictionary vals where keys are the fields to be updated, and values are the new values for those fields. |
| Target | Can be called on a specific record or a set of records that match a certain domain. | Called on the model itself, not on a specific record. |
| Triggers | Executes `@api.onchange` methods and `@api.depends` decorated methods, triggering related computations or updates. | Bypasses `@api.onchange` methods and `@api.depends` decorated methods, without triggering additional computations or updates. |
| Returns | Returns True if the update is successful. | Returns nothing. |

General Considerations:

- 'write' is suitable when updating specific fields of individual records or a set of records, and when triggering related computations or updates.
- 'update' is useful when updating multiple records efficiently, without invoking `@api.onchange` or `@api.depends` mechanisms. When dealing with `@api.onchange` methods and pseudo-records, update can be used to modify field values, as pseudo-records are not yet saved in the database.

## Difference between @api.onchange and @api.depends

In Odoo, there are two decorators, `@api.depends` and `@api.onchange`, which serve different purposes when working with fields in models.

The `@api.depends` decorator is used for "fields.function" in Odoo. It allows you to calculate the value of a field based on other fields within the same or related models. When any of the fields specified in the decorator are altered or changed in the form, the decorated function is triggered, and the field's value is recalculated. This decorator provides a way to establish field dependencies across different screens and models.

On the other hand, the `@api.onchange` decorator is used to trigger a specific function when any of the specified fields change within the same screen or model. It enables you to perform custom actions or computations based on the changed values.

While it is possible to combine `@api.depends` and `@api.onchange` decorators, it is generally not necessary or recommended to use them together for the same fields. The `@api.depends` decorator already handles the field dependencies and triggers the method when any of the specified fields change, including the fields that you might specify in `@api.onchange`.

Here's an example to illustrate the usage of `@api.depends` and `@api.onchange` separately:

```py
class MyModel(models.Model):
    _name = 'my.model'

    field1 = fields.Char()
    field2 = fields.Integer()
    field3 = fields.Boolean()
    computed_field = fields.Float(compute='_compute_field')

    @api.depends('field1', 'field2')
    def _compute_field(self):
        # Perform calculations based on field1 and field2
        # ...

        # Update the value of the computed_field
        self.computed_field = calculated_value

    @api.onchange('field3')
    def _onchange_field3(self):
        # Perform specific actions when field3 is changed
        # ...

        # Update the value of the computed_field or other fields if needed
        self.computed_field = new_value
```

In the example above, the method _compute_field is decorated with `@api.depends`, specifying that it should be called whenever field1 or field2 changes. This allows for recalculating the value of the computed_field based on the values of those fields.

The method _onchange_field3 is decorated with `@api.onchange` for field3, which triggers the method when the value of field3 changes. This allows for performing custom actions specific to the change in field3 and updating the computed_field or any other relevant fields accordingly.

Remember, it is generally recommended to use either `@api.depends` or `@api.onchange` based on your specific requirements, rather than combining them for the same fields. This approach avoids redundancy and ensures clear and concise code.



## List of special commands

These commands allows to assign a value/s to One2many or Many2many

-   `(0, 0, { values })` adds a new record (write *values* on it)
-   `(1, ID, { values })` update the linked record with id = ID (write *values* on it), can not be used in ~.create.
-   `(2, ID)` remove and delete the linked record with id = ID (calls unlink on ID, that will delete the object completely, and the link to it as well), can not be used in ~.create.
-   `(3, ID)` cut the link to the linked record with id = ID (delete the relationship between the two objects but does not delete the target object itself), can not be used in ~.create.
-   `(4, ID)` link to existing record with id = ID (adds a relationship), can not be used on ~odoo.fields.One2many.
-   `(5)` unlink all (like using (3,ID) for all linked records), can not be used on ~odoo.fields.One2many and can not be used in ~.create.
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

## List of ondelete options

'ondelete' defines what happens when the related record is deleted.

Its default is set *null*, meaning that an empty value is set when the related record is deleted.

Other possible values are *restricted*, raising an error preventing the deletion, and *cascade*, which also deletes this record.