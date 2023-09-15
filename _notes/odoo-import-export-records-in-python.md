---
layout: note
title: Odoo Import/Export records in python
draft: false
date: 2023-09-15 18:00:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

Import the required Python libraries and Odoo tools at the beginning of your Python script. These libraries will be used in the import and export operations.

```py
import base64
import csv
import io
import zipfile
import re
import pytz

from datetime import datetime, timezone
from odoo.tools import pycompat
```

Export records from Odoo models, such as 'sale.order' and 'sale.order.line,' and package them into a ZIP archive.

```py
def export(self):
    so = self.env['sale.order'].with_context(import_compat=True).search([])
    sol = self.env['sale.order.line'].with_context(import_compat=True).search([])
    models = ['sale.order', 'sale.order.line']

    zip_buffer = io.BytesIO()
    with zipfile.ZipFile(zip_buffer, mode="w") as zip_archive:
        for model in models:
            csv_file = io.StringIO()
            writer = csv.writer(csv_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

            match model:
                case 'sale.order':
                    fields = ['name', 'id']
                    datas = so.export_data(fields).get('datas', [])
                case 'sale.order.line':
                    fields = ['name', 'id', 'order_id/id']
                    datas = sol.export_data(fields).get('datas', [])

            writer.writerows([fields])
            for data in datas:
                row = []
                for d in data:
                    row.append(pycompat.to_text(d))
                writer.writerow(row)

            zip_archive.writestr(model, csv_file.getvalue())

    datetime_str = datetime.now(timezone.utc).astimezone(pytz.timezone('Europe/Brussels')).strftime("%Y%m%d-%H%M%S")
    zip_filename = datetime_str + '.zip'

    attachment_id = self.env['ir.attachment'].create({
        'name': zip_filename,
        'datas': base64.b64encode(zip_buffer.getvalue()),
        'res_model': 'export.website.wizard',
        'res_id': self.id
    })
    self.env['ir.attachment']._file_delete(attachment_id.store_fname)

    return {
        'type': 'ir.actions.act_url',
        'url': "web/content/?model=ir.attachment&id=" + 
            str(attachment_id.id) +
            "&filename_field=name&field=datas&download=true&name=" +
            attachment_id.name,
        'target': 'self',
    }
```

Sorts a dictionary based on a specified order (list) of keys.

```py
def sort_dict_by_list(un_dict, ordination: [str]) -> [int]:
    sorted_dict = dict()
    sorted_list = list((i, un_dict.get(i)) for i in ordination)
    for i in sorted_list:
        sorted_dict.setdefault(i[0], i[1])
    return sorted_dict
```

Import records and execute the import in Odoo.

```py
def _import_record_and_execute(self, model, decoded_csv, fields):
    import_record = self.env['base_import.import'].create({
        'res_model': model,
        'file': decoded_csv,
        'file_type': 'text/csv',
        'file_name': model,
    })
    result = import_record.execute_import(
        fields,
        fields,
        {'quoting': '"', 'separator': ',', 'has_headers': True},
        False
    )
    return result
```

Import records from a ZIP archive containing CSV files for 'sale.order' and 'sale.order.line' models. Execute the import in Odoo.

```py
def import(self):
    decoded_zip = base64.b64decode(self.zip_file)
    io_bytes_zip = io.BytesIO(decoded_zip)

    if zipfile.is_zipfile(io_bytes_zip):
    with zipfile.ZipFile(io_bytes_zip, mode="r") as archive:
        csv_files = sort_dict_by_list({name: archive.read(name) for name in archive.namelist()}, ['sale.order', 'sale.order.line'])

    for model in csv_files:
        decoded_csv = csv_files[model].decode()
        io_string_csv = io.StringIO(decoded_csv)
        csvreader = csv.reader(io_string_csv)
        parsed_arch = []
        fields = []
        for row in csvreader:
            fields = row
        result = self._import_record_and_execute(model, decoded_csv, fields)
```
