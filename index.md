---
layout: default
title: Home
order: "1"
pagination:
  enabled: false
---

# Home

Hi!👋️ My name is Victor.

## Skills

<div class="m-skill">
  <p><b>Languages:</b> French (mother tongue), English (full professional proficiency).</p>
  <p><b>Langages:</b> Java, Python, PHP, SQL, C, C#, HTML, CSS, JavaScript/jQuery/TypeScript, Shell, Bash.</p>
  <p><b>Technologies:</b> Odoo, Spring Boot, Angular, Android, NSIS.</p>
  <p><b>Systems:</b> Windows, Windows Server, Linux.</p>
</div>

## Experiences

<ul class="experiences finished">
{% for experience in site.experiences reversed %}
    <li class="experience">
        <h3>{{ experience.post }}</h3>
        <small><b>{{ experience.business }}</b> • <i>{{ experience.start_year }} - {{ experience.end_year }}</i></small>
        <p>{{ experience.content }}</p>
    </li>
{% endfor %}
</ul>

## Educations

<ul class="educations finished">
{% for education in site.educations reversed %}
    <li class="education">
        <h3>{{ education.study }}</h3>
        <small><b>{{ education.degree }} • {{ education.school }}</b> • <i>{{ education.start_year }} - {{ education.end_year }}</i></small>
    </li>
{% endfor %}
</ul>

## Projects

<ul class="projects finished">
{% for project in site.projects reversed %}
    {% unless project.draft %}
        <li class="project">
            <h3><a class="name" href="{{ project.url | relative_url }}">
               {{ project.title }}
            </a></h3>
            {{ project.excerpt }}
        </li>
    {% endunless %}
{% endfor %}
</ul>
