---
layout: note
draft: false
title: Configuring Odoo Logging to Seq with pygelf
date: 2022-05-11 09:55:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

⚠️ **Warning:** tested on Odoo 11.0, 13.0, 15.0, 16.0, 17.0, and 18.0.

⚠️ **Warning:** Seq logging captures user data, starting the service may lock the `users` and `partners` tables, which can block or even crash updates. To prevent this, temporarily disable Seq logging during any update operations.

## Install the pygelf package

⚠️ **Warning:** the latest release of pygelf is version 0.4.2, and it has not been updated since October 2021.

Install the `pygelf` package using pip:

```bash
pip install pygelf
```

## Update the Odoo configuration

In the `__init__(self, fname=None)` method from the `configmanager` class, add this line to introduce a new logging option for Seq::

```py
group.add_option('--log-seq', dest='log_seq', help="Logging to seq")
```

When starting the Odoo server, you can specify the Seq server in one of two ways:

- **Command Line:**  
  ```bash
  ./odoo-bin --log-seq=seq-server:port
  ```
  
- **Configuration File:**  
  Add the following to your `odoo.conf` file:
  ```ini
  log_seq = seq-server:port
  ```

The default port for data ingress with GELF is **12201**.

## Modify the Odoo Logger

Add in the import section of the `odoo/netsvc.py` file:

```py
from pygelf import GelfUdpHandler, gelp
gelf.LEVELS.update({25: 6})  # Add custom level for Odoo RUNBOT
```

Add Custom Logging Filters and Formatter include the following classes:

```py
class uidFilterSeq(logging.Filter):
    def filter(self, record):
        # Add the current db name to the log record
        ct = threading.current_thread()
        ct_db = getattr(ct, 'dbname', None)
        dbname = tools.config['log_db'] if tools.config['log_db'] and tools.config['log_db'] != '%d' else ct_db
        if dbname:
            record.dbname = dbname
        if odoo and odoo.http and odoo.http.request:
            user_id = False
            try:
                if odoo.http.request.uid:
                    user_id = odoo.http.request.uid
                elif odoo.http.request.session.uid:
                    user_id = odoo.http.request.session.uid
            except Exception:
                pass
            if user_id:
                record.user_id = user_id
            if odoo.http.request.httprequest.cookies and 'visitor_uuid' in odoo.http.request.httprequest.cookies:
                record.visitor_id = odoo.http.request.httprequest.cookies['visitor_uuid']
            if odoo.http.request.httprequest.remote_addr:
                record.client_address = odoo.http.request.httprequest.remote_addr
        return True

class PerfFilterSeq(logging.Filter):
    def filter(self, record):
        if hasattr(threading.current_thread(), "query_count"):
            query_count = threading.current_thread().query_count
            query_time = threading.current_thread().query_time
            perf_t0 = threading.current_thread().perf_t0
            remaining_time = time.time() - perf_t0 - query_time
            record.perf_info = {'query_count': "%d" % query_count,
                                'query_time': "%.3f" % query_time,
                                'remaining_time': "%.3f" % remaining_time}
            delattr(threading.current_thread(), "query_count")
        return True

class DBFormatterSeq(logging.Formatter):
    def format(self, record):
        record.pid = os.getpid()
        return logging.Formatter.format(self, record)
```

Integrate the Seq Logging Handler. After the blocks handling `tools.config['syslog']:` and `elif tools.config['logfile']:`, add this snippet to configure Seq logging:

```py
elif tools.config['log_seq']:
    loghost = tools.config['log_seq']
    handler = GelfUdpHandler(
        host=str(loghost.split(':')[0]), port=int(loghost.split(':')[1]),
        include_extra_fields=True, debug=True
    )
```

Then, between the block that checks for a POSIX system with a TTY stream and the `else:` clause, insert the following code:

```py
elif isinstance(handler, GelfUdpHandler):
    formatter = DBFormatterSeq(format)
    perf_filter = PerfFilterSeq()
    handler.addFilter(uidFilterSeq())
```
