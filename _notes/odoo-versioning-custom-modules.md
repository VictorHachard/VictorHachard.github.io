---
layout: note
draft: false
date: 2023-09-18 11:31:00 +0200
author: Victor Hachard
categories: ['Odoo']
---

[Original article](https://www.odoo.com/fr_FR/forum/aide-1/how-should-one-version-their-patches-to-their-custom-modules-130124)

When versioning custom Odoo modules, adhere to these guidelines:

- The version number in the module manifest should follow this format: `<Odoo major version>.x.y.z`.
- For example, the first release of an 8.0 module should be versioned as `8.0.1.0.0`.
- The x.y.z version numbers signify:
  - x: Significant changes to data models or views, possibly requiring data migration.
  - y: Non-breaking new features added, likely necessitating a module upgrade.
  - z: Bug fixes that might require a server restart.
- Include migration instructions or scripts for breaking changes.
- When porting a module to different Odoo versions, handle versioning as follows:
  - If an update is only added to one version, change the version accordingly.
  - Ensure that the same version numbers do not have different meanings across module branches.

Examples:

- The version is changed as in the example below:

  - *Init:*
    - Odoo 8.0: 8.0.1.0.0
    - Odoo 9.0: 9.0.1.0.0

  - *Feature added to 8.0 and ported to 9.0:*
    - Odoo 8.0: 8.0.1.1.0
    - Odoo 9.0: 9.0.1.1.0

  - *Feature added to 9.0 only and not going to be ported to 8.0:*
    - Odoo 8.0: 8.0.1.1.0
    - Odoo 9.0: 9.0.1.2.0

  - *Fix made in 9.0 only and not going to be ported to 8.0:*
    - Odoo 8.0: 8.0.1.1.0
    - Odoo 9.0: 9.0.1.2.1

  - *Fix made in 8.0 and ported to 9.0:*
    - Odoo 8.0: 8.0.1.2.2
    - Odoo 9.0: 9.0.1.2.2
