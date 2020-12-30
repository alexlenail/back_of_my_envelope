{%- extends 'basic.tpl' -%}

{% block codecell %}
    {{ "{% raw %}" }}
    {{ super() }}
    {{ "{% endraw %}" }}
{% endblock codecell %}

{% block input_group -%}
    {%- if cell.metadata.hide_input or nb.metadata.hide_input -%}
    {%- elif cell.metadata.collapse_hide -%}
        <div class="collapsible collapsed">
            <a class="collapse-button" onclick="this.parentElement.classList.toggle('collapsed');"><i class="fas fa-ellipsis-h"></i></a>
            {{ super() }}
        </div>
    {%- elif cell.metadata.collapse_show -%}
        <div class="collapsible">
            <a class="collapse-button" onclick="this.parentElement.classList.toggle('collapsed');"><i class="fas fa-ellipsis-h"></i></a>
            {{ super() }}
        </div>
    {%- else -%}
        {{ super() }}
    {%- endif -%}
{% endblock input_group %}

{% block output_group -%}
    {%- if cell.metadata.hide_output -%}
    {%- else -%}
        {{ super()  }}
    {%- endif -%}
{% endblock output_group %}

{% block output_area_prompt %}
    {%- if cell.metadata.hide_input or nb.metadata.hide_input -%}
       <div class="prompt"> </div>
    {%- else -%}
        {{ super()  }}
    {%- endif -%}
{% endblock output_area_prompt %}

