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

{% for project in site.projects reversed %}
<ul>
<li><a href="{{ project.url | relative_url }}">{{ project.title }}</a></li>
</ul>
{% endfor %}

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
            {% if project.references[0] %}
                <ul class="references">
                {% for reference in project.references %}
                    <li><a href="{{reference}}">{{ reference }}</a></li>
                {% endfor %}
                </ul>
            {% endif %}
        </li>
    {% endunless %}
{% endfor %}
</ul>

## Experience



## Education

<div class="uk-grid-large uk-child-width-1-3@s uk-child-width-1 uk-text-center uk-flex-center uk-grid uk-grid-stack" uk-grid="" style="padding-left: 20px; padding-right: 20px">


    <div class="uk-first-column">
        <div class="uk-card uk-card-default uk-height-max-large">
            <div class="uk-card-media-top">
                <img class="contain experience" src="res/home/heh.png" alt="" style="padding: 20px" loading="lazy">
            </div>
            <div class="uk-card-body" style="padding-top: 0">
                <div style="height: 5em">
                    <h3 class="uk-card-title">University of Mons</h3>
                </div>
                <p style="height: 4em">Bachelor in Computer Science</p>
                <p>2017 - 2020</p>
            </div>
        </div>
    </div>

    <div class="uk-grid-margin uk-first-column">
        <div class="uk-card uk-card-default uk-height-max-large">
            <div class="uk-card-media-top">
                <img class="contain experience" src="res/home/umons.png" alt="" style="padding: 20px" loading="lazy">
            </div>
            <div class="uk-card-body" style="padding-top: 0">
                <div style="height: 5em">
                    <h3 class="uk-card-title">University of Montreal</h3>
                </div>
                <p style="height: 4em">Exchange at the Department of Computer Science and Operations Research</p>
                <p>Autumn 2019</p>
            </div>
        </div>
    </div>

    <div class="uk-grid-margin uk-first-column">
        <div class="uk-card uk-card-default uk-height-max-large">
            <div class="uk-card-media-top">
                <img class="contain experience" src="res/home/saint-luc.png" alt="" style="padding: 20px" loading="lazy">
            </div>
            <div class="uk-card-body" style="padding-top: 0">
                <div style="height: 5em">
                    <h3 class="uk-card-title">University of Mons</h3>
                </div>
                <p style="height: 4em">Master in Computer Science</p>
                <p>2020 - Present</p>
            </div>
        </div>
    </div>

</div>
</div>
