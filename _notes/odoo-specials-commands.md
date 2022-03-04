---
title: Odoo specials commands for creating records in one2many relation
layout: note
draft: false
date: 2022-03-04 14:42:00 +0200
author: Victor Hachard
---

## List of commands

-   `(1, ID, { values })` update the linked record with id = ID (write *values* on it)
-   `(2, ID)` remove and delete the linked record with id = ID (calls unlink on ID, that will delete the object completely, and the link to it as well)
-   `(3, ID)` cut the link to the linked record with id = ID (delete the relationship between the two objects but does not delete the target object itself)
-   `(4, ID)` link to existing record with id = ID (adds a relationship)
-   `(5) ` unlink all (like using (3,ID) for all linked records)
-   `(6, 0, [IDs])` replace the list of linked IDs (like using (5) then (4,ID) for each ID in the list of IDs)
