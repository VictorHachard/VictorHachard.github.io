---
layout: note
title: Odoo Report Template (pdf, qweb)
draft: true
date: 2023-08-11 14:44:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

Inherit `ir.actions.report` and override the `_run_wkhtmltopdf` method.

```py
@api.model
def _run_wkhtmltopdf(
    self,
    bodies,
    header=None,
    footer=None,
    landscape=False,
    specific_paperformat_args=None,
    set_viewport_size=False
):
    pdf_content = super()._run_wkhtmltopdf(bodies, header, footer, landscape, specific_paperformat_args, set_viewport_size)

    pdf_file = io.BytesIO(pdf_content)
    input_pdf = PdfFileReader(pdf_file)
    img_path = get_resource_path('your_module', 'static/description/watermark_pdf.pdf')
    watermark_pdf = ''
    with tools.file_open(img_path, 'rb') as f:
        watermark_pdf = base64.b64encode(f.read())

    watermark_file = PdfFileReader(io.BytesIO(base64.b64decode(test)))
    watermark_page = watermark_file.getPage(0)
    width = watermark_page.mediaBox.getWidth()
    height = watermark_page.mediaBox.getHeight()

    output = PdfFileWriter()

    for i in range(input_pdf.getNumPages()):
        output.addBlankPage(width, height)

    for i in range(output.getNumPages()):
        pdf_page = output.getPage(i)
        pdf_page.mergePage(watermark_page)
        pdf_page.mergePage(input_pdf.getPage(i))

    merged_pdf_buffer = io.BytesIO()
    output.write(merged_pdf_buffer)
    merged_pdf_bytes = merged_pdf_buffer.getvalue()

    return merged_pdf_bytes
```

Optionally, you can remove the white background of the original pdf file with the following code before the super call:

```py
header_str = str(header)
header_str = header_str.replace('<meta charset="utf-8"/>',
                                '<meta charset="utf-8"/><style>body, div , main {background-color: transparent !important;}</style>')
header = M(header_str)

footer_str = str(footer)
footer_str = footer_str.replace('<meta charset="utf-8"/>',
                                '<meta charset="utf-8"/><style>body, div , main {background-color: transparent !important;}</style>')
footer = M(footer_str)
bodiesd = []
for body in bodies:
    body_str = str(body)
    body_str = body_str.replace('<meta charset="utf-8"/>',
                                '<meta charset="utf-8"/><style>body, div , main {background-color: transparent !important;}</style>')
    body = M(body_str)
    bodiesd.append(body)
bodies = bodiesd
```
