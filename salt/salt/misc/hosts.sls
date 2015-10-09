{% from 'vars.jinja' import server_id, host_entries with context %}

etc-hosts-entries:
  host.present:
    - ip: 127.0.0.1
    - names:
      - localhost
      - {{ server_id }}
{% for entry in host_entries %}
      - {{ entry }}
{% endfor %}

