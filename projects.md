---
title: Projects
layout: default
permalink: /projects/
order: "2"
---

<h1 class="post-title p-name">Projects</h1>
<p class="post-meta">
    {% assign projectsCount = site.projects | size %}
    {% if projectsCount == 1 %}
        1 project
    {% elsif projectsCount > 1 %}
        {{ projectsCount }} projects
    {% endif %}
</p>

I work on projects from time to time, and I try to publish them here. If you have learn something, that's great. If you're an inspiration, that's better.

&nbsp;

<ul class="projects finished">
{% for project in site.projects reversed %}
    <li class="project">
        <h2>
            <a class="name" href="{{ project.url | relative_url }}">
                {{ project.title }}
            </a>
        </h2>
        {{ project.excerpt }}
        {% if project.references[0] %}
            <ul class="references">
            {% for reference in project.references %}
                <li><a href="{{reference}}">{{ reference }}</a></li>
            {% endfor %}
            </ul>
        {% endif %}
    </li>
{% endfor %}
</ul>

<ul class="projects drafted">
{% for project in site.projects %}
    {% if project.draft %}
        <li class="project draft">
            <h2>
                <a class="name" href="{{ project.url | relative_url }}">
                    {{ project.title }}
                </a>
            </h2>
            {{ project.excerpt }}
            {% if project.references[0] %}
                <ul class="references">
                {% for reference in project.references %}
                    <li><a href="{{reference}}">{{ reference }}</a></li>
                {% endfor %}
                </ul>
            {% endif %}
        </li>
    {% endif %}
{% endfor %}
</ul>
