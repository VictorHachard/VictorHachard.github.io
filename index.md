---
layout: default
title: Home
order: "1"
pagination:
  enabled: false
---

# Home

Hi!👋️ My name is Victor.
I'm a Computer Science Student.

## Projects

<ul class="projects finished">
{% for project in site.projects reversed %}
    {% unless project.draft %}
        <li class="project">
            <h2>
                <a class="name" href="{{ project.url | relative_url }}">
                    {{ project.title }}
                </a>
            </h2>
            {{ project.excerpt }}
        </li>
    {% endunless %}
{% endfor %}
</ul>

## Experience



## Education

<img class="contain experience" src="res/home/heh.png" alt="" style="padding: 20px" loading="lazy">

<img class="contain experience" src="res/home/umons.png" alt="" style="padding: 20px" loading="lazy">

<img class="contain experience" src="res/home/saint-luc.png" alt="" style="padding: 20px" loading="lazy">
