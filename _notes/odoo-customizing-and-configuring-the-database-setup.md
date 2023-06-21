---
layout: note
title: Odoo Customizing and Configuring the Database Setup
draft: false
date: 2023-06-21 14:07:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

To customizing and configuring the database setup. Add a new key-value pair to the dictionary with the key `post_init_hook` and the value as the name of the function you want to use as the post-init hook.

```py
{
    'name': 'Your Module Name',
    'version': '1.0',
    'summary': 'Summary of your module',
    'description': 'Description of your module',
    'author': 'Your Name',
    'category': 'Category',
    'depends': ['base'],
    'data': [
        # Other module data files
    ],
    'installable': True,
    'post_init_hook': 'your_module_name._post_init',
}
```

Update the `__init__.py` file to include the `_post_init` function, In this example the `_post_init(cr, registry)` function do the following:

- Activates the French language ('fr_FR') in the 'res.lang' model.
- Calls the `_auto_activate(env)` function to automatically activates a specific configuration setting.
- Updates various fields of the 'base.main_company' record, such as name, website, email, address, VAT number, invoice terms, logo, colors, etc.
- Updates translations for the 'invoice_terms' field in French.
- Calls the `_remove_onboarding(env)` and `_remove_digest(env)` functions to clean up onboarding and digest related data.
- Creates a new 'base.document.layout' record, assigns it to the main company, and sets the font and report layout for document printing.
- Updates the 'report_footer' field of the 'base.main_company' record.
- Creates a new product template for a web service and sets the appropriate taxes, type, and other properties.
- Sets a configuration parameter 'service_product_id' with the ID of the created service product template.

```py
# -*- coding: utf-8 -*-
import base64
import logging

from odoo import SUPERUSER_ID, api, tools, _
from odoo.modules import get_resource_path


_logger = logging.getLogger(__name__)


def _remove_digest(env):
    env.ref('digest.digest_digest_default').write({
        'state': 'deactivated',
    })


def _remove_onboarding(env):
    env.ref('base.main_company').write({
        'account_setup_bank_data_state': 'done',
        'account_setup_fy_data_state': 'done',
        'account_setup_coa_state': 'done',
        'account_setup_taxes_state': 'done',
        'account_onboarding_invoice_layout_state': 'done',
        'account_onboarding_create_invoice_state': 'done',
        'account_onboarding_sale_tax_state': 'done',
        'account_invoice_onboarding_state': 'closed',
        'account_dashboard_onboarding_state': 'closed',
        'account_setup_bill_state': 'done',
        'sale_quotation_onboarding_state': 'closed',
        'sale_onboarding_order_confirmation_state': 'done',
        'sale_onboarding_sample_quotation_state': 'done',
    })


def _auto_activate(env):
    env['res.config.settings'].create({
        'use_invoice_terms': True,
    }).execute()


def get_resource(filename):
    img_path = get_resource_path('dashan', 'static/assets/' + filename)
    with tools.file_open(img_path, 'rb') as f:
        return base64.b64encode(f.read())


def _post_init(cr, registry):
    logging.info("Post initialization")

    env = api.Environment(cr, SUPERUSER_ID, {})

    env['res.lang']._activate_lang('fr_FR')

    env.cr.commit()

    _auto_activate(env)

    env.ref('base.main_company').write({
        'name': 'Victor',
        'website': 'https://victorhachard.fr/',
        'email': 'hello@victorhachard.fr',
        'street': '',
        'zip': '',
        'city': '',
        'vat': '',
        'invoice_terms': "The customer acknowledges having read and accepted the general conditions of sale listed at the following address: https://victorhachard.fr/conditions-generales-de-vente/",
        'country_id': env.ref('base.be').id,
        'logo': get_resource('icon.png'),
        'external_report_layout_id': env.ref('web.external_layout_standard').id,
        'primary_color': '#ffffff',
        'secondary_color': '#ffffff',
    })

    env.ref('base.main_company').update_field_translations('invoice_terms', {
        'fr_FR': "Le client reconnait avoir pris connaissance et accepté les conditions générales de vente reprises à l'adresse suivante : https://victorhachard.fr/conditions-generales-de-vente/"
    })

    _remove_onboarding(env)
    _remove_digest(env)

    env.cr.commit()

    bdl = env['base.document.layout'].create({
        'company_id': env.ref('base.main_company').id,
        'font': 'Roboto',
        'report_layout_id': env.ref('web.report_layout_boxed').id,
    })
    bdl._onchange_custom_colors()
    bdl.document_layout_save()

    env.ref('base.main_company').write({
        'report_footer': 'VICTOR | hello@victorhachard.fr | victorhachard.fr'
    })

    env.cr.commit()

    service_tmpl_id = env['product.template'].create({
        'name': 'Web Site',
        'taxes_id': [(6, 0, env['account.tax'].search([('name', '=', '21%')]).ids)],
        'detailed_type': 'service',
        'purchase_ok': False,
        'sale_ok': True
    })

    env['ir.config_parameter'].sudo().set_param('service_product_id', str(service_tmpl_id.id))

    logging.info("Finish post initialization")
```
