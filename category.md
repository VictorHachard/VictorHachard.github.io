---
title: Categories
layout: default
permalink: /categories/
order: "5"
---

<h1 class="post-title p-name">Categories</h1>
<p class="post-meta">
    {% assign categoriesCount = site.categories | size %}
    {% if categoriesCount == 1 %}
        1 category
    {% elsif categoriesCount > 1 %}
        {{ categoriesCount }} categories
    {% endif %}
</p>

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
