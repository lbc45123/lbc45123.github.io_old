---
layout: single
permalink: /
hidden: true
---

<h2>Notable Projects</h2>
<div class="feature__wrapper">
{% for post in site.portfolio %}
  {% include archive-single.html type="grid" %}
{% endfor %}
</div>
