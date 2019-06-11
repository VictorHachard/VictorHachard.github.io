---
title: WTD
layout: default
permalink: /wtd/
order: "3"
---

# Who to do

I work on think from time to time, when I understand something that I know I will forget I publish them here. If you have learn something, that's great. If you're an inspiration, that's better.

&nbsp;

<ul class="projects finished">
{% for wtd in site.wtds %}
    {% unless wtd.draft %}
        <li class="project">
            <h2>
                <a class="name" href="{{ wtd.url | relative_url }}">
                    {{ wtd.title }}
                </a>
            </h2>
        </li>
    {% endunless %}
{% endfor %}
</ul>
