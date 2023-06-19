---
layout: note
draft: false
date: 2023-06-14 14:44:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

`_reopen_self` when triggered, opens a new window with a form view of the same wizard model. This can be useful when you want to guide the user through a step-by-step process or gather specific information.

```py
class ExampleWizard(models.TransientModel):
    _name = "example.wizard"
    _description = "Example Wizard"

    def action(self):
        return self._reopen_self()

    def _reopen_self(self):
        return {
            "type": "ir.actions.act_window",
            "res_model": self._name,
            "res_id": self.id,
            "name": self._description,
            "view_mode": "form",
            "target": "new",
        }
```
