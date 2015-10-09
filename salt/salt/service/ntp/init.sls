ntp-package:
  pkg.installed:
    - name: ntp

ntpd-service:
  service.running:
    - name: ntp
    - enable: true
    - require:
      - pkg: ntp

