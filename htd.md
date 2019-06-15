---
title: HTD
layout: default
permalink: /htd/
order: "3"
---

# How to do

I work on think from time to time, when I understand something that I know I will forget I publish them here. If you have learn something, that's great. If you're an inspiration, that's better.

&nbsp;

<ul class="projects finished">
{% for htd in site.htds reversed %}
    {% unless htd.draft %}
        <li class="project">
            <h2>
                <a class="name" href="{{ htd.url | relative_url }}">
                    {{ htd.title }}
                </a>
            </h2>
            <p>
                {{ htd.content | number_of_words }} words published on {{ htd.date | date: "%B %d, %Y" }}
            </p>
        </li>
    {% endunless %}
{% endfor %}
</ul>
