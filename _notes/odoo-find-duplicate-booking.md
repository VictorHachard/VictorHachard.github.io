---
layout: note
title: Odoo Find Duplicate Booking in SQL
draft: false
date: 2023-06-14 14:44:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

`check_duplicate_bookings_new` performs the following steps:

1. Retrieve existing bookings with the duplicate field set to True.
2. Construct and execute a SQL query to find distinct booking IDs where the check-in and check-out dates overlap for bookings with the same room.
3. Retrieve the corresponding booking records based on the SQL query results.
4. Identify bookings that are present in both the existing bookings and the new query results.
5. Create two lists: bookings_old (bookings in the existing bookings but not in bookings_match) and bookings (bookings in the new query results but not in bookings_match).
6. Set the duplicate field to True for bookings in the bookings list.
7. Set the duplicate field to False for bookings in the bookings_old list.
8. Commit the changes to the database.
9. Stop the timer and log the execution time and some logging information.

```py
def check_duplicate_bookings_new(self):
    """
    Check if there is bookings with the same room and overlapping dates.
    """
    tic = time.perf_counter()

    bookings_old = self.env['sale.order.line'].search([('duplicate', '=', True)])
    self.env.cr.commit()
    sql = """
        with sol as (
          select
            sol.*
          from
            sale_order_line sol
            join sale_order so on so.id = sol.order_id
          where
            so.state in ('draft', 'sent', 'sale')
            and sol.checkout > CURRENT_DATE
            and sol.rental = true
        )
        select distinct
          sol1.id
        from
          sol as sol1
          inner join sol as sol2 on sol1.id != sol2.id
          and sol1.room_id = sol2.room_id
          and sol1.checkin < sol2.checkout
          and sol1.checkout > sol2.checkin
    """
    self.env.cr.execute(sql)
    bookings = self.env['sale.order.line'].browse(row[0] for row in self.env.cr.fetchall())

    bookings_match = [x for x in bookings_old if x in bookings]

    bookings_old = [x for x in bookings_old if x not in bookings_match]
    bookings = [x for x in bookings if x not in bookings_match]

    if bookings:
        self.env['sale.order.line'].search([('id', 'in', [x.id for x in bookings])]).write({'duplicate': True})
    if bookings_old:
        self.env['sale.order.line'].search([('id', 'in', [x.id for x in bookings_old])]).write({'duplicate': False})
    self.env.cr.commit()

    toc = time.perf_counter()
    _logger.info(f'Check duplicate booking done in {toc - tic:0.4f}, found {len(bookings)} occurrence',
                    extra={'duplicate_sol_ids': [b.id for b in bookings],
                        'duplicate_so': [b.order_id.name for b in bookings]})
```
