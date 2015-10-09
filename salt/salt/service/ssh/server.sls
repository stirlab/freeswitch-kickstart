{% from 'vars.jinja' import sshd_port with context %}

openssh-server:
  pkg.installed

/etc/ssh/sshd_config:
  file:
    - managed
    - template: jinja
    - context:
      sshd_port: {{ sshd_port }}
    - source: salt://etc/ssh/sshd_config.jinja
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: openssh-server

sshd-service:
  service.running:
    - enable: True
    - name: ssh
    - watch:
      - pkg: openssh-server
      - file: /etc/ssh/sshd_config
