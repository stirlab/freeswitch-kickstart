{% from 'vars.jinja' import server_env, server_id with context %}

/etc/hostname:
  file:
    - managed
    - template: jinja
    - context:
      server_env: {{ server_env }}
      server_id: {{ server_id }}
    - source: salt://etc/hostname.jinja
    - user: root
    - group: root
    - mode: 644

set-hostname:
  cmd.run:
    - name: hostname {{ server_id }}
    - unless: test "$(hostname)" = "{{ server_id }}"

