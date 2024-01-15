---
layout: note
draft: false
date: 2024-01-15 14:51:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

Auto refresh views in Odoo 16.

For a tree view first create a new controller:

```js
/** @odoo-module */

import { ListController } from "@web/views/list/list_controller";

import { onWillStart, onWillDestroy } from "@odoo/owl";

export class RefreshListController extends ListController {
    setup() {
        super.setup();
        this._interval = null;
        onWillStart(async () => {
            this._interval = setInterval(this.refreshData.bind(this), 5000);
        });
        onWillDestroy(() => {
            clearInterval(this._interval);
        });
    }
    async refreshData() {
        await this.model.root.load();
        this.render(true);
    }
}
```

Then register a new view:

```js
/** @odoo-module **/

import { registry } from "@web/core/registry";
import { listView } from "@web/views/list/list_view";
import { RefreshListController } from "@<module_name>/tree_view/refresh_controller";

export const ListView = {
    ...listView,
    Controller: RefreshListController,
};

registry.category("views").add("refresh_list", ListView);
```

Finally, add the new view to the tree view:

```xml
<record id="refresh_tree_view" model="ir.ui.view">
    <field name="name">refresh.auction.tree</field>
    <field name="model">refresh.auction</field>
    <field name="arch" type="xml">
        <tree js_class="refresh_list">
            <field name="name"/>
        </tree>
    </field>
</record>
```
