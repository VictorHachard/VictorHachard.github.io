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

`self.write(vals)`: This method is used to update existing record(s) in the database. It takes a dictionary vals as an argument, where the keys are the fields to be updated, and the values are the new values for those fields. The write method returns True if the update is successful.

```py
def update_product_price(self, product_id, new_price):
    product = self.env['product.product'].browse(product_id)
    product.write({'list_price': new_price})
```

### Update

`self.update(vals)`: This method is used to update a record. It takes a dictionary vals as an argument, similar to self.write(), but it not savec in database. The update method returns mothing.

```py
def update_product_price(self, product_id, new_price):
    product = self.env['product.product'].browse(product_id)
    products.update({'list_price': new_price})
```

### Key differences between the update and write methods

| | Write | Update |
| --- | --- | --- |
| Usage | Used to update existing record(s) in the database. | Used to update a pseudo-record (in `@api.onchange`, ...) |
| Arguments <td colspan=2> Takes a dictionary vals where keys are the fields to be updated, and values are the new values for those fields. |
| Target | Can be called on a specific record or a set of records. | Called on the model itself (a record). |
| Triggers | Executes related computations methods (`@api.onchange`, `@api.depends`, ...) or updates. | Bypasses related computations methods or updates. |
| Returns | Returns True if the update is successful. | Returns nothing. |

## Method Decorators

### @api.depends

The `@api.depends` decorator is used for "fields.function". It allows you to calculate the value of a field based on other fields within the same or related models. When any of the fields specified in the decorator are altered or changed, the decorated function is triggered, and the field's value is recalculated. This decorator provides a way to establish field dependencies across different screens and models.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    field1 = fields.Char()
    field2 = fields.Integer()
    computed_field = fields.Float(compute='_compute_field')

    @api.depends('field1', 'field2')
    def _compute_field(self):
        # Perform calculations based on field1 and field2
        # ...

        # Update the value of the computed_field
        self.computed_field = calculated_value
```

In the example above, the method `_compute_field` is decorated with `@api.depends`, specifying that it should be called whenever field1 or field2 changes. This allows for recalculating the value of the computed_field based on the values of those fields.

### @api.depends_context

The `@api.depends_context` decorator is used to define a method that depends on specific values from the context. The decorated method will be recomputed whenever any of the specified keys in the context changes.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    field = fields.Char()
    computed_field = fields.Float(compute='_compute_field')

    @api.depends_context('my_context_key')
    @api.depends('field')
    def _compute_field(self):
        # Access the value from the context
        context_value = self.env.context.get('my_context_key')

        # Perform calculations based on field and context_value
        # ...

        # Update the value of the computed_field
        self.computed_field = calculated_value
```

In the example above, the method `_compute_field` is decorated with `@api.depends_context('my_context_key')`. It specifies that the method should be recomputed whenever the value of the key 'my_context_key' in the context changes, in addition to the regular dependency on the 'field'. This allows for dynamic computations based on both the field value and the context value.

### @api.onchange

The `@api.onchange` decorator is used to trigger a specific function when any of the specified fields change within the same screen or model. It enables you to perform custom actions or computations based on the changed values.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    field3 = fields.Boolean()
    computed_field = fields.Float()

    @api.onchange('field3')
    def _onchange_field3(self):
        # Perform specific actions when field3 is changed
        # ...

        # Update the value of the computed_field or other fields if needed
        self.computed_field = new_value
```

In the example above, the  method `_onchange_field3` is decorated with `@api.onchange` for field3, which triggers the method when the value of field3 changes. This allows for performing custom actions specific to the change in field3 and updating the computed_field or any other relevant fields accordingly.

### @api.constraints

The `@api.constraints` decorator is used to define constraints on a model. It allows you to specify rules that the model's records must follow to maintain data integrity. The decorated method is called whenever the constraint is evaluated.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    field = fields.Integer()

    @api.constraints('field')
    def _check_field_constraint(self):
        for record in self:
            if record.field < 0:
                raise models.ValidationError("Field value must be positive.")
```

In the example above, the method `_check_field_constraint` is decorated with `@api.constraints('field')`. It specifies that the constraint should be checked whenever the 'field' value is modified. If any record violates the constraint (field value is negative), a validation error is raised.

### @api.model_create_multi

The `@api.model_create_multi` decorator is used to optimize the creation of multiple records in a single database query. It is applied to a method that creates multiple records at once.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    @api.model_create_multi
    def create(self, vals_list):
        for vals in vals_list:
            if not vals.get('field'):
                vals.update({'field': False})
        return super().create(vals_list)
```

In the example above, the method `create` is decorated with `@api.model_create_multi`. This decorator enhances the performance by creating the records in a single database query, rather than individual queries for each record.

### @api.autovacuum

The `@api.autovacuum` decorator is used to mark a method as a "cleanup" method. It is automatically called by Odoo during a database vacuum operation, which helps optimize the database performance. This decorator is typically used for methods that perform cleanup tasks or remove outdated records.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    @api.autovacuum
    def _perform_cleanup(self):
        # Perform cleanup tasks or delete outdated records
        # ...
        return self.sudo().search(domain).unlink()
```

In the example above, the method `_perform_cleanup` is decorated with `@api.autovacuum`. When Odoo performs a database vacuum operation, it will automatically call this method to execute the defined cleanup tasks.

### Between method

It is generally recommended to use either `@api.depends` or `@api.onchange` based on your specific requirements, rather than combining them for the same fields. This approach avoids redundancy and ensures clear and concise code.


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