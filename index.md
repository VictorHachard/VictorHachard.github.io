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

## Experiences

<ul class="experiences finished">
{% for experience in site.experiences reversed %}
    <li class="experience">
        <h2>{{ experience.post }}</h2>
        <p>{{ experience.business }} • {{ experience.start_year }} - {{ experience.end_year }} <br> {{ experience.content }}
        </p>
    </li>
{% endfor %}
</ul>

## Educations

<ul class="educations finished">
{% for education in site.educations reversed %}
    <li class="education">
        <h2>{{ education.study }}</h2>
        <p>{{ education.degree }} • {{ education.school }} • {{ education.start_year }} - {{ education.end_year }}</p>
    </li>
{% endfor %}
</ul>
