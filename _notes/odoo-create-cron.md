---
layout: note
draft: false
date: 2023-11-17 14:17:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

Create a cron job in Odoo.

This cron job will be executed every day at 1:30 AM. One day is removed to force the execution after the installation of the module.

```xml
<record id="unlink_unused_attribute_values" model="ir.cron">
    <field name="name">Product Attribute: Delete Unused Attribute Value</field>
    <field name="model_id" ref="model_product_attribute"/>
    <field name="state">code</field>
    <field name="code">model._unlink_unused_attribute_values()</field>
    <field name='interval_number'>1</field>
    <field name='interval_type'>days</field>
    <field name="active" eval="False"/>
    <field name="numbercall">-1</field>
    <field name="nextcall" eval="(DateTime.now() - relativedelta(days=1)).strftime('%Y-%m-%d 01:30:00')"/>
</record>
```
