---
layout: note
title: Odoo Add Field in Many2many Relation
draft: false
date: 2022-06-24 10:27:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

<pre class="mermaid">
classDiagram
    class FieldMapper {
        technical_name: Char
        name: Char
        field_mapper_line_ids: FieldMapperLine
        field_mapper_ids: FieldMapperFieldMapperLineRel
    }
    class FieldMapperLine {
        target_field: Char
        field_mapper_ids: FieldMapper
        field_mapper_line_ids: FieldMapperFieldMapperLineRel
    }
    class FieldMapperFieldMapperLineRel {
        field_mapper_id: FieldMapper
        field_mapper_line_id: FieldMapperLine
        sequence: Integer
    }
    
    FieldMapper -- FieldMapperFieldMapperLineRel
    FieldMapperLine -- FieldMapperFieldMapperLineRel
    FieldMapper -- FieldMapperLine
</pre>

The `FieldMapperFieldMapperLineRel` class represents a relational table that establishes a many-to-many relationship between `FieldMapper` and `FieldMapperLine`.

```py
class FieldMapperFieldMapperLineRel(models.Model):
    _name = 'field.mapper.field.mapper.line'
    _description = 'Field Mapper Relation'
    _table = 'field_mapper_field_mapper_line_rel'
    _rec_name = 'field_mapper_id'

    def _default_sequence(self):
        record = self.search([], limit=1, order="sequence DESC")
        if record:
            return record.sequence + 5
        return 10000

    field_mapper_id = fields.Many2one(
        comodel_name='field.mapper',
        string='Field Mapper',
        ondelete='cascade',
        required=True
    )
    field_mapper_line_id = fields.Many2one(
        comodel_name='field.mapper.line',
        string='Field Mapper Line',
        ondelete='cascade',
        required=True
    )
    sequence = fields.Integer(string='Sequence', required=True, index=True, default=_default_sequence)

    _sql_constraints = [
        ('field_mapper_field_line_mapper_uniq', 'unique (field_mapper_line_id, field_mapper_id)',
            'Field Mapper Line and Field Mapper must be unique!'),
    ]
```

```py
class FieldMapper(models.Model):
    _name = 'field.mapper'
    _description = 'Field mapper'

    technical_name = fields.Char(string='Technical Name', required=True)
    name = fields.Char(string='Name', required=True)

    field_mapper_line_ids = fields.Many2many(
        comodel_name='field.mapper.line',
        relation='field_mapper_field_mapper_line_rel',
        column1='field_mapper_id',
        column2='field_mapper_line_id',
        string='Field Mapper Line'
    )
    field_mapper_ids = fields.One2many(
        comodel_name='field.mapper.field.mapper.line',
        inverse_name='field_mapper_id',
        string='Field Rel'
    )
```

```py
class FieldMapperLine(models.Model):
    _name = 'field.mapper.line'
    _description = 'Field Mapper Line'

    field_mapper_ids = fields.Many2many(
        comodel_name='field.mapper',
        relation='field_mapper_field_mapper_line_rel',
        column1='field_mapper_line_id',
        column2='field_mapper_id',
        string='Field Mapper'
    )
    field_mapper_line_ids = fields.One2many(
        comodel_name='field.mapper.field.mapper.line',
        inverse_name='field_mapper_line_id',
        string='Field Rel'
    )

    target_field = fields.Char(string='Target Field', required=True)
```
