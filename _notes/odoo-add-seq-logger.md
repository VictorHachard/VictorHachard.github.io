---
layout: note
draft: false
date: 2022-05-11 09:55:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

This has been tested on Odoo 13.0, 15.0 and 16.0.

## Add the `pygelf` package:

Add the following lines in the `requirements.txt` file:

```py
pygelf
```

## The `odoo/service/server.py` file:

In the `__init__(self, fname=None)` method from the `configmanager` class add the following lines:

```py
group.add_option('--log-seq', dest='log_seq', help="Logging to seq")
```

## The `odoo/netscv` file:

Add the following lines in the `odoo/netsvc.py` file:

```py
class uidFilterSeq(logging.Filter):
    def filter(self, record):
        if odoo and odoo.http and odoo.http.request:
            if odoo.http.request.uid or odoo.http.request.session.uid:
                if odoo.http.request.uid:
                    user_id = odoo.http.request.uid
                elif odoo.http.request.session.uid:
                    user_id = odoo.http.request.session.uid
                if odoo.http.request.uid or odoo.http.request.session.uid:
                    record.user_id = user_id
                    # res = get_partner_user(user_id)
                    # if res:
                    #     record.user_partner = {'user_id': res['user_id'],
                    #                            'user_login': res['user_login'],
                    #                            'partner_id': res['partner_id'],
                    #                            'partner_name': res['partner_name']}
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

After the if `tools.config['syslog']:` and `elif tools.config['logfile']:` add the following lines:

```py
elif tools.cronfig['log_seq']:
    loghost = tools.config['log_seq']

    def record_factory_seq(*args, **kwargs):
        record = old_factory(*args, **kwargs)
        # We need to change the runbot to info level because seq don't have a runbot level
        if record.levelno == logging.RUNBOT:
            record.levelno = logging.INFO
        return record

    logging.setLogRecordFactory(record_factory_seq)
    handler = GelfUdpHandler(host=str(loghost.split(':')[0]),
                                port=int(loghost.split(':')[1]),
                                include_extra_fields=True,
                                debug=Tue)
```

Between the `if os.name == 'posix' and isinstance(handler, logging.StreamHandler) and is_a_tty(handler.stream):` and the `else:` add the following lines:

```py
elif isinstance(handler, GelfUdpHandler):
    formatter = DBFormatterSeq(format)
    perf_filter = PerfFilterSeq()
    handler.addFilter(uidFilterSeq())
```

## In the config file:

Add the following lines in the config file (replace the IP address and the port if needed):

```py
log_seq = 127.0.0.1:12201
```
