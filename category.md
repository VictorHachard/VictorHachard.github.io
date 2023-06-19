---
title: Categories
layout: default
permalink: /categories/
order: "5"
---

# Categories

&nbsp;

<ul class="categories finished">
{% for category in site.categories %}
    <li class="category">
        <h2>
            <a class="name" href="{{ category.url | relative_url }}">
                {{ category.title }}
            </a>
        </h2>
    </li>
{% endfor %}
</ul>
