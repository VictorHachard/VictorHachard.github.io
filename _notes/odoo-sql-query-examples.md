---
layout: note
title: Odoo SQL Query Examples
draft: false
date: 2022-07-15 08:05:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

## Get torrent that have an outdated revision

Retrieves the IDs of pirate torrents that don't have a revision or one of the revision is outdated (not the latest). 

<!-- ![sql-diagram]({{site.baseurl}}/res/sql-102/1.png) -->

```sql
WITH rev AS (
  SELECT MAX(id) AS id
  FROM pirate_revision
  GROUP BY revision_type
)
SELECT pt.id
FROM pirate_torrent pt
WHERE pt.state IN ('saved', 'exist')
  AND (
    SELECT COUNT(*)
    FROM pirate_revision_pirate_torrent_rel prptr
    WHERE prptr.torrent_id = pt.id
      AND prptr.revision_id IN (SELECT id FROM rev)
  ) < (SELECT COUNT(id) FROM rev)
LIMIT 100000;
```

## Get duplicate sale order

Retrieves the distinct IDs of sale order lines that are associated with sale orders in the 'draft', 'sent', or 'sale' states, and have at least one other sale order line associated with the same sale order.

```sql
WITH sol AS (
  SELECT sol.*
  FROM sale_order_line sol
  JOIN sale_order so ON so.id = sol.order_id
  WHERE so.state IN ('draft', 'sent', 'sale')
)
SELECT DISTINCT sol1.id
FROM sol AS sol1
INNER JOIN sol AS sol2 ON sol1.id != sol2.id;
```

## Get product.attribute.value ordered by name

Retrieves the IDs of product.attribute.value ordered by name.

```sql
SELECT pav.id
FROM product_attribute pa
LEFT JOIN product_attribute_value pav ON pav.attribute_id = pa.id
WHERE pa.bypass_sequence = True
ORDER BY pav.name;
```

## Get all the product.template.attribute.value that are not actually used

Retrieves the IDs of product.template.attribute.value that are not active and have no active product.template.attribute.value associated with the same product.attribute.value.

```sql
SELECT DISTINCT pav.id
FROM product_attribute_value pav
left JOIN product_template_attribute_value ptav ON ptav.product_attribute_value_id = pav.id
WHERE ptav.product_attribute_value_id IS null or (
    ptav.ptav_active = false
    and pav.id NOT IN (
        SELECT ptav_sub.product_attribute_value_id
        FROM product_template_attribute_value ptav_sub
        WHERE ptav_sub.ptav_active = true
    )
);
```

## Get all the product.public.category that are not actually used

Retrieves the IDs of product.public.category that are not active and have no active product.public.category associated with the same parent_id.

```sql
SELECT ppc.id 
FROM product_public_category ppc
WHERE ppc.is_last_level = True AND NOT EXISTS (
    SELECT *
    FROM product_public_category_product_template_rel ppcptr
    WHERE ppcptr.product_public_category_id = ppc.id 
);
```
