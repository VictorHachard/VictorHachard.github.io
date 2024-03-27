---
layout: note
draft: false
date: 2023-02-02 09:39:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

```py
def _get_user_formatted_datetime(self, date):
    tz = pytz.timezone(self.env.user.tz or 'UTC')
    lang = get_lang(self.env)
    date = date.replace(tzinfo=timezone.utc).astimezone(tz)
    return date.strftime(("%s %s" % (lang.date_format, lang.time_format)))
```
