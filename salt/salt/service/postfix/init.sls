{% from 'vars.jinja' import server_id with context %}

postfix-package:
  pkg.installed:
    - name: postfix

postfix-service:
  service.running:
    - name: postfix
    - enable: true
    - watch:
      - pkg: postfix-package
