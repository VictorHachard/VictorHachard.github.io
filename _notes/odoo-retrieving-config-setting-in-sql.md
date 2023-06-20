---
layout: note
title: Odoo Retrieving Config Setting in SQL
draft: false
date: 2023-06-20 11:44:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

Within the `res.config.settings` model, two fields are declared: `report_forecast_month` and `report_past_month`. These fields represent some configuration. Each field is associated with a configuration parameter key (`config_parameter`) named `'report_forecast_month'` and `'report_past_month'`.

```py
class ResConfigSettings(models.TransientModel):
    _inherit = 'res.config.settings'

    report_forecast_month = fields.Integer(string='Report Forecast Month', default=12, config_parameter='report_forecast_month')
    report_past_month = fields.Integer(string='Report Past Month', default=24, config_parameter='report_past_month')
```

Retrieve configuration settings within an SQL query. It utilizes a common table expression (CTE) named config.

```sql
with config as (
    select
        date_trunc('month', CURRENT_DATE) + interval '1 month' - interval '1 day' + interval '1 month' * coalesce((select icp.value
        from ir_config_parameter icp
        where icp."key" = 'report_forecast_month')::integer, 12) as forecast,
        date_trunc('month', CURRENT_DATE) - interval '1 month' * coalesce((select icp.value
        from ir_config_parameter icp
        where icp."key" = 'report_past_month')::integer, 24) as past
)
```

Using the CTE `config`, we can calculate the start date for the past period and then join it with the `sales` table to filter the data accordingly.

```sql
select *
from sales
join config on sales.order_date >= config.past;
```
