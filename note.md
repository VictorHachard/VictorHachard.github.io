---
title: Notes
layout: default
permalink: /notes/
order: "4"
---

{% assign count = 0 %}
{% for note in site.notes %}
    {% if note.active != false %}
        {% assign count = count | plus: 1 %}
    {% endif %}
{% endfor %}

<h1 class="post-title p-name">Notes</h1>
<p class="post-meta">
    {% if count == 1 %}
        1 post
    {% elsif count > 1 %}
        {{ count }} posts
    {% endif %}
</p>

Whenever I come across an insight that I anticipate forgetting, I make sure to share it here. If you have learn something, that's great. If you're an inspiration, that's better.

&nbsp;

<ul class="projects finished">
{% for note in site.notes reversed %}
    {% if note.active != false %}
        <li class="project">
            <h2>
                <a class="name" href="{{ note.url | relative_url }}">
                    {{ note.title }}
                </a>
            </h2>
            <p>
                {{ note.content | strip_html | number_of_words }} words published on {{ note.date | date: "%B %d, %Y" }} 
                {%- if note.categories and note.categories.size != 0 -%}
                    &nbsp;in
                    {% for category in note.categories %}
                        <span itemprop="category" itemscope itemtype="http://schema.org/CategoryCode">
                        <a class="p-category h-card" itemprop="name" href="{{ site.baseurl }}/categories/{{ category | slugify }}">{{ category }} </a>{% unless forloop.last %}, {% endunless %}
                        </span>
                    {% endfor %}
                {%- endif -%}
            </p>
        </li>
    {% endif %}
{% endfor %}
</ul>
