---
layout: note
draft: false
date: 2023-06-14 14:44:00 +0200
author: Victor Hachard
---

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
