{% from 'vars.jinja' import server_env, sshd_port with context %}

firewall-packages:
  pkg.installed:
    - pkgs:
      - iptables
      - shorewall

/etc/default/shorewall:
  file.managed:
    - source: salt://etc/default/shorewall
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: firewall-packages

/etc/shorewall/interfaces:
  file.managed:
    - source: salt://etc/shorewall/interfaces
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: firewall-packages

/etc/shorewall/policy:
  file.managed:
    - source: salt://etc/shorewall/policy
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: firewall-packages

/etc/shorewall/rules:
  file.managed:
    - template: jinja
    - context:
      server_env: {{ server_env }}
      sshd_port: {{ sshd_port }}
    - source: salt://etc/shorewall/rules.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: firewall-packages

/etc/shorewall/zones:
  file.managed:
    - source: salt://etc/shorewall/zones
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: firewall-packages

firewall-service:
  service.running:
    - name: shorewall
    - enable: true
    - watch:
      - pkg: firewall-packages
      - file: /etc/default/shorewall
      - file: /etc/shorewall/interfaces
      - file: /etc/shorewall/policy
      - file: /etc/shorewall/rules
      - file: /etc/shorewall/zones
