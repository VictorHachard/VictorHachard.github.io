---
title: Projects
layout: default
permalink: /projects/
order: "2"
---

{% assign count = 0 %}
{% for note in site.projects %}
    {% if note.active != false %}
        {% assign count = count | plus: 1 %}
    {% endif %}
{% endfor %}

<h1 class="post-title p-name">Projects</h1>
<p class="post-meta">
    {% if count == 1 %}
        1 project
    {% elsif count > 1 %}
        {{ count }} projects
    {% endif %}
</p>

I work on projects from time to time, and I try to publish them here. If you have learn something, that's great. If you're an inspiration, that's better.

&nbsp;

<ul class="projects finished">
{% for project in site.projects reversed %}
    {% if project.active != false %}
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
    {% endif %}
{% endfor %}
</ul>

<ul class="projects drafted">
{% for project in site.projects %}
    {% if project.active != false %}
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
    {% endif %}
{% endfor %}
</ul>
