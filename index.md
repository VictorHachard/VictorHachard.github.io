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



## Educations

<ul class="educations finished" style="list-style: none;">
{% for education in site.educations reversed %}
        <li class="education">
            <img src="res/home/{{ education.logo }}" alt="logo {{ education.school }}" style="max-width:300px;width:100%;padding-bottom:8px;" loading="lazy">
            <h2>{{ education.study }}</h2>
            <p>{{ education.degree }} • {{ education.school }} • {{ education.start_year }} - {{ education.end_year }}</p>
        </li>
{% endfor %}
</ul>
