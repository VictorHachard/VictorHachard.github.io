---
layout: project
title: mail-it
draft: false
date: 2023-06-01 00:00:00 +0200
author: Victor Hachard
languages:
    - Java
    - Spring Boot (Java)
githubs: 
    - github.com/VictorHachard/mail-it
---

mail-it is a Spring API that allows web applications to easily send email to your mailbox using Google's email service.

mail-it offers features such as domain whitelisting and an alias system.

The domain whitelisting feature allows which domains are allowed to send emails through the mail-it API, providing an additional level of security and control.

The alias system allows sending emails using aliases instead of actual email address to protect privacy.

## Code Example

```html
<form action="https://mail-it.example.com/you_email@example.com" method="POST">
    <input type="text" name="fromName" placeholder="Your name">
    <input type="email" name="replyTo" placeholder="Your email">
    <input type="text" name="subject" placeholder="Your subject">
    <input type="text" name="message" placeholder="Your message">
    <input type="submit" value="Send Email">
</form>
```

The [wiki](https://github.com/VictorHachard/mail-it/wiki/Angular-implementation) contains additional code examples.

## What I Learned

- Spring Boot
- Google's email service
- Server-side development (services, nginx, etc.)
