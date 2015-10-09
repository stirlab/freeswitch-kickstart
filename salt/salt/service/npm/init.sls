include:
  - service.nodejs

{% from 'vars.jinja' import server_env with context %}

npm-package:
  pkg.installed:
    - name: npm
    - require:
      - pkg: nodejs-packages

nodemon-package:
  npm.installed:
    - name: nodemon
    - user: root
    - require:
      - pkg: npm-package

