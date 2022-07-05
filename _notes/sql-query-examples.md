---
layout: note
draft: false
date: 2022-07-15 08:05:00 +0200
author: Victor Hachard
---

## Get torrent that have an outdated revision

Select all torrents that don't have a revision or one of the revision is outdated (not the latest).

![sql-diagram]({{site.baseurl}}/res/sql-102/1.png)

```sql
with rev as (select MAX(id) as id from pirate_revision group by revision_type)  /*select all revision (last one of each type)*/
select pt.id from pirate_torrent pt
where pt.state in ('saved', 'exist') and (
  select COUNT(*) from pirate_revision_pirate_torrent_rel prptr
  where prptr.torrent_id = pt.id and prptr.revision_id in (select id from rev)
) < (select count(id) from rev) limit 100000
```

## Get duplicate sale order

Select all sale order that are duplicated.

```sql
with sol as (select sol.* from sale_order_line sol
  join sale_order so on so.id = sol.order_id
  where so.state in ('draft', 'sent', 'sale'))
select distinct sol1.id from sol as sol1 inner join sol as sol2 on sol1.id != sol2.id

```