---
layout: note
draft: true
date: 2022-02-01 18:00:00 +0200
author: Victor Hachard
---

## Two main solutions to this problem

-   Implement an Amazon-style "pending order" logic (see) : the product's stock is updated when the order is placed and order is held during a few minutes, allowing the user to checkout. If the order is cancelled, the transaction rollbacks. (it is also used for plane or cinema tickets example).
-   Use psql transaction isolation as suggested by @sauloperez or stuff like Optimistic Offline Lock, which is a native ActiveRecord module. The flow would be something like : a user add products to his cart and their availability is re-checked right before checkout to make sure they're still available. If not, the user gets an error or a message like "This product is missing, etc...".


Whole books have been written on concurrency, it's a major issue we're tackling here. What do you think ? The user-friendly solution would be the first one I think, it avoids users to go through an order and have an error on checkout, which is pretty annoying.

*HugsDaniel on 12 Feb 2018*