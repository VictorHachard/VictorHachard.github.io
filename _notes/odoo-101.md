---
layout: note
draft: false
date: 2022-03-04 14:42:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

## TODO

Add more ORM methods
Add translation in python


## ORM methods

### Default Get

`default_get(self, fields)`: This method is used to provide default values for fields when creating a new record. It takes a list of field names as an argument and returns a dictionary with the default values for those fields.

```py
def default_get(self, fields_list):
    defaults = super().default_get(fields_list)
    defaults['price'] = 100
    return defaults
```

### Read

### New

`new(self, values)`: This method is used to create a new record without saving it to the database. It takes a dictionary values as an argument, where the keys are the fields of the record, and the values are the corresponding values for those fields. The new method returns a new record object.

```py
product = self.env['product.product'].new({'name': name, 'list_price': price})
```

Note that you would typically call the `create` method to create a new record that is saved to the database, but the `new` method can be useful in certain scenarios where you want to work with a record object temporarily before deciding whether to save it or not.

### Create

`self.create(vals)`: This method is used to create new records in the database. It takes a dictionary vals as an argument, where the keys are the fields of the new record, and the values are the values for those fields. The create method returns the newly created record.

```py
product = self.env['product.product'].create({'name': name, 'list_price': price})
```

### Copy

### Unlink

`self.unlink()`: This method is used to delete records from the database. It removes the record associated with the current instance of the model. The unlink method returns True if the deletion is successful.

```py
product = self.env['product.product'].browse(1)
product.unlink()
```

### Write

`self.write(vals)`: This method is used to update existing record(s) in the database. It takes a dictionary vals as an argument, where the keys are the fields to be updated, and the values are the new values for those fields. The write method returns True if the update is successful.

```py
product = self.env['product.product'].browse(product_id)
product.write({'list_price': new_price})
```

### Update

`self.update(vals)`: This method is used to update a record. It takes a dictionary vals as an argument, similar to self.write(), but it not savec in database. The update method returns mothing.

```py
product = self.env['product.product'].browse(product_id)
products.update({'list_price': new_price})
```

### Key differences between the update and write methods

| | Write | Update |
| --- | --- | --- |
| Usage | Used to update existing record(s) in the database. | Used to update a pseudo-record/record in a `@api.onchange` or a `@api.depends`. |
| Arguments | <td colspan="2"> Takes a dictionary vals where keys are the fields to be updated, and values are the new values for those fields. |
| Target | Can be called on a specific record or a set of records. | Called on the model itself (a record). |
| Triggers | Executes related computations methods (`@api.depends`, ...). | Bypasses related computations methods. |
| Returns | Returns `True` if the update is successful. | Returns `None`. |

## Method Decorators

### @api.depends

The `@api.depends` decorator is used for "fields.function". It allows you to calculate the value of a field based on other fields within the same or related models. When any of the fields specified in the decorator are altered or changed, the decorated function is triggered, and the field's value is recalculated. This decorator provides a way to establish field dependencies across different screens and models.

When working with a single record in a view (such as updating a record in a form view), self represents a pseudo record.

When working with a set of records (for example, when using the write() method to update multiple records), self refers to the set of records.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    debit = fields.Float()
    credit = fields.Float()
    balance = fields.Float(compute='_compute_balance')

    @api.depends('debit', 'credit')
    def _compute_balance(self):
        for record in self:
            record.balance = record.debit - record.credit
```

Another way to write the code:

```py
    @api.depends('debit', 'credit')
    def _compute_balance(self):
        for record in self:
            record.update({
                'balance': record.debit - record.credit
            })
```

### @api.depends_context

The `@api.depends_context` decorator is used to define a method that depends on specific values from the context. The decorated method will be recomputed whenever any of the specified keys in the context changes.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    employee_ids = fields.Many2many('hr.employee')
    employee_id = fields.Many2one('hr.employee', compute='_compute_company_employee')

    @api.depends_context('company')
    @api.depends('employee_ids')
    def _compute_company_employee(self):
        company = self.env.context.get('company')
        for record in self:        
            self.employee_id = self.env['hr.employee'].search([
                ('id', 'in', rec.employee_ids.ids),
                ('company_id', '=', self.env.company.id)],
                limit=1)
```

### @api.onchange

The `@api.onchange` decorator is used to trigger a specific function when any of the specified fields change within the same screen or model. It enables you to perform custom actions or computations based on the changed values.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    done = fields.Boolean()
    nice_done = field.Char()

    @api.onchange('done')
    def _onchange_done(self):
        self.nice_done = 'Done' if self.done else 'TODO'
```

Since `@onchange` returns a pseudo-records, calling any one of the CRUD methods (`create`, `read`, `write`, `unlink`) on the aforementioned recordset is undefined behaviour, as they potentially do not exist in the database yet.

Instead, simply set the record’s field like shown in the example above or call the `update` method.

```py
    @api.onchange('done')
    def _onchange_done(self):
        self.update({
            'nice_done': 'Done' if self.done else 'TODO'
        })
```

### @api.constrains

The `@api.constrains` decorator is used to define constrains on a model. It allows you to specify rules that the model's records must follow to maintain data integrity. The decorated method is called whenever the constrain is evaluated.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    field = fields.Integer()

    @api.constrains('field')
    def _check_field_constrain(self):
        for record in self:
            if record.field < 0:
                raise ValidationError("Field value must be positive.")
```

`@constrains` will be triggered only if the declared fields in the decorated method are included in the `create` or `write` call. It implies that fields not present in a view will not trigger a call during a record creation. A override of `create` is necessary to make sure a constrain will always be triggered (e.g. to test the absence of value).

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

### @api.autovacuum

The `@api.autovacuum` decorator is used to mark a method as a "cleanup" method. It is automatically called by Odoo during a database vacuum operation, which helps optimize the database performance. This decorator is typically used for methods that perform cleanup tasks or remove outdated records.

Example:

```py
class MyModel(models.Model):
    _name = 'my.model'

    @api.autovacuum
    def _perform_cleanup(self):
        return self.sudo().search(domain).unlink()
```

### @api.ondelete

The `@api.ondelete` decorator in Odoo is used to mark a method to be executed during the unlink() operation. This decorator allows you to define business rules and conditions that restrict the deletion of records. It is particularly useful when you want to prevent the deletion of certain records that are not intended to be deleted from a business perspective.

One important advantage of using @api.ondelete is that it ensures compatibility with module uninstallation. When a module is uninstalled, the overridden unlink() method may raise errors that could interfere with the uninstallation process, leaving the database in an inconsistent state. By using @api.ondelete, you can avoid such issues and ensure that all records related to the module are properly removed during uninstallation.

```py
class UserModel(models.Model):
    _name = 'user.model'

    @api.ondelete(at_uninstall=False)
    def _unlink_if_user_inactive(self):
        if any(user.active for user in self):
            raise UserError("Can't delete an active user!")

    @api.ondelete(at_uninstall=False)
    def _unlink_except_active_user(self):
        if any(user.active for user in self):
            raise UserError("Can't delete an active user!")
```

### @api.returns

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

## Field parameters

## ondelete

`ondelete`, you can control the behavior of related records when the referenced record is deleted, ensuring data consistency and integrity.

```py
class ChildModel(models.Model):
    _name = 'child.model'

    parent_id = fields.Many2one('parent.model', ondelete='cascade')
```

- `'set null'`: Sets the field value to null when the referenced record is deleted (default).
- `'restrict'`: Prevents the deletion of the referenced record if there are dependent records.
- `'no action'`: No action is taken when the referenced record is deleted.
