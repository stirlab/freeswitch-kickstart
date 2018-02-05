{% from 'vars.jinja' import
  nvm_node_versions,
with context %}

include:
  - software.nvm

nodemon-package:
  npm.installed:
    - name: nodemon
    - user: root
    - require:
{% for version in nvm_node_versions %}
      - cmd: nvm-install-{{ version }}
{% endfor %}

