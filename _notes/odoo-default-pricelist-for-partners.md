---
layout: note
title: Odoo Default Pricelist for Partners
draft: false
date: 2022-06-20 11:21:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

To set a default pricelist for partners in Odoo, you can follow these steps:

1. Inherit the `res.config.settings` model:

```py
class ResConfigSettings(models.TransientModel):
    _inherit = 'res.config.settings'

    partner_pricelist_id = fields.Many2one(
        'product.pricelist', string='Default Pricelist for Partners',
        help='Default Pricelist for Partners.',
        config_parameter='sale.partner_pricelist_id')

    @api.model
    def get_values(self):
        res = super().get_values()
        partner_pricelist_id = self.env['ir.config_parameter'].sudo().get_param('sale.partner_pricelist_id')
        res.update(partner_pricelist_id=int(partner_pricelist_id) if partner_pricelist_id else False)
        return res

    @api.model
    def set_values(self):
        super().set_values()
        self.env['ir.config_parameter'].sudo().set_param('sale.partner_pricelist_id', str(self.partner_pricelist_id.id))
```

2. Inherit the `res.partner` model:


    The `compute` method `_compute_partner_pricelist_id` calculates the value of the `partner_pricelist_id` field based on the `property_product_pricelist` field. If `sproperty_product_pricelist` is set, it assigns its value to `partner_pricelist_id`. Otherwise, it retrieves the default pricelist for partners from the configuration settings.

    The `inverse` method `_set_partner_pricelist_id` ensures that when `partner_pricelist_id` is modified, it updates the `property_product_pricelist `field accordingly, ensuring synchronization between the two fields.

    The `property_product_pricelist` field represents the pricelist assigned to a partner. It can be manually set or computed based on default settings. It determines the appropriate pricelist for the partner during sales or related processes.


```py
class ResPartner(models.Model):
    _inherit = 'res.partner'

    partner_pricelist_id = fields.Many2one(
        'product.pricelist', string='Default Pricelist',
        help='Default Pricelist for this Partner.',
        compute='_compute_partner_pricelist_id', inverse='_set_partner_pricelist_id', store=True)

    @api.depends('property_product_pricelist')
    def _compute_partner_pricelist_id(self):
        for partner in self:
            if partner.property_product_pricelist:
                partner.partner_pricelist_id = partner.property_product_pricelist
            else:
                partner_pricelist_id = self.env['ir.config_parameter'].sudo().get_param('sale.partner_pricelist_id')
                partner.partner_pricelist_id = self.env['product.pricelist'].browse(int(partner_pricelist_id)) if partner_pricelist_id else False

    def _set_partner_pricelist_id(self):
        for partner in self:
            partner.property_product_pricelist = partner.partner_pricelist_id

    def copy(self, default=None):
        self.ensure_one()
        default = dict(default or {})
        default['property_product_pricelist'] = False
        return super().copy(default)
```

3. Create XML views for the configuration settings and partner form:

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>

        <record id="view_sale_configuration_settings_inherited" model="ir.ui.view">
            <field name="name">sale.config.settings.inherit</field>
            <field name="model">res.config.settings</field>
            <field name="inherit_id" ref="sale.res_config_settings_view_form"/>
            <field name="arch" type="xml">
                <xpath expr="//div[@id='pricelist_configuration']//div[hasclass('content-group')]/div[hasclass('mt16')]" position="after">
                    <div class="form-group">
                        <label class="col-sm-3 control-label" for="partner_pricelist_id">Default Pricelist for Partners</label>
                        <div class="col-sm-9">
                            <field name="partner_pricelist_id" widget="selection"/>
                        </div>
                    </div>
                </xpath>
            </field>
        </record>

        <record id="res_partner_view_form_inherit" model="ir.ui.view">
            <field name="name">res.partner.form.inherit</field>
            <field name="model">res.partner</field>
            <field name="inherit_id" ref="base.view_partner_form"/>
            <field name="arch" type="xml">
            <field name="property_product_pricelist" position="replace">
                <field name="partner_pricelist_id" widget="selection" groups="product.group_product_pricelist" required="1"
                       attrs="{'invisible': [('is_company', '=', False), ('parent_id', '!=', False)]}"/>
                </field>
            </field>
        </record>

    </data>
</odoo>
```

4. Create a module with the following details in the manifest file:

```python
# -*- coding: utf-8 -*-
{
    'name': "Default Pricelist for Partners",
    'summary': """""",
    'description': """""",
    'author': "",
    'license': 'Other proprietary',
    'website': "",
    'category': 'Technical',
    'version': '0.1',
    'depends': ['base', 'sale'],
    'data': [
        'views/res_config_setting.xml',
        'views/res_partner.xml',
    ],
    'installable': True,
    'auto_install': False,
    'application': False,
}
```
