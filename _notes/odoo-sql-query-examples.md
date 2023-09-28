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
