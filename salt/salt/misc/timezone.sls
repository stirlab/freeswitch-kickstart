{% from 'vars.jinja' import server_timezone with context %}

server-timezone:
  timezone.system:
    - name: {{ server_timezone }}

