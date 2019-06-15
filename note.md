---
title: Note
layout: default
permalink: /note/
order: "4"
---

# How to do

I work on think from time to time, when I understand something that I know I will forget I publish them here. If you have learn something, that's great. If you're an inspiration, that's better.

&nbsp;

<ul class="projects finished">
{% for note in site.notes reversed %}
    {% unless note.draft %}
        <li class="project">
            <h2>
                <a class="name" href="{{ note.url | relative_url }}">
                    {{ note.title }}
                </a>
            </h2>
            <p>
                {{ note.content | number_of_words }} words published on {{ note.date | date: "%B %d, %Y" }}
            </p>
        </li>
    {% endunless %}
{% endfor %}
</ul>
