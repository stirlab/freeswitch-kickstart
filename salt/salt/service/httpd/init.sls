{% from 'vars.jinja' import server_id with context %}

httpd-packages:
  pkg.installed:
    - pkgs:
      - apache2
      - php5
      - libapache2-mod-php5

/var/log/httpd_site_logs:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - pkg: httpd-packages

apache-enabled-ssl-module:
  apache_module.enable:
    - name: ssl
    - require:
      - pkg: httpd-packages

apache-enabled-rewrite-module:
  apache_module.enable:
    - name: rewrite
    - require:
      - pkg: httpd-packages

apache-enable-default-ssl-site:
  cmd.run:
    - name: /usr/sbin/a2ensite default-ssl
    - require:
      - pkg: httpd-packages
    - unless: test -L /etc/apache2/sites-enabled/default-ssl.conf

/etc/apache2/sites-available/default-ssl.conf:
  file.managed:
    - source: salt://etc/apache2/sites-available/default-ssl.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: httpd-packages

/etc/apache2/apache2.conf:
  file.managed:
    - source: salt://etc/apache2/apache2.conf
    - user: root
    - group: root
    - mode: 644

/etc/apache2/conf-available/security.conf:
  file.managed:
    - source: salt://etc/apache2/conf-available/security.conf
    - user: root
    - group: root
    - mode: 644

/etc/apache2/mods-available/ssl.conf:
  file.managed:
    - source: salt://etc/apache2/mods-available/ssl.conf
    - user: root
    - group: root
    - mode: 644

/etc/ssl/certs/cert.pem:
  file.managed:
    - source: salt://etc/ssl/cert.pem
    - user: root
    - group: root
    - mode: 644

/etc/ssl/certs/chain.pem:
  file.managed:
    - source: salt://etc/ssl/chain.pem
    - user: root
    - group: root
    - mode: 644

/etc/ssl/private/key.pem:
  file.managed:
    - source: salt://etc/ssl/key.pem
    - user: root
    - group: root
    - mode: 640

/var/www/html/.htaccess:
  file.managed:
    - template: jinja
    - context:
      server_id: {{ server_id }}
    - source: salt://service/httpd/htaccess.jinja
    - user: root
    - group: www-data
    - mode: 640
    - require:
      - pkg: httpd-packages

httpd-service:
  service.running:
    - name: apache2
    - enable: true
    - watch:
      - pkg: httpd-packages
      - apache_module: apache-enabled-ssl-module
      - apache_module: apache-enabled-rewrite-module
      - file: /etc/apache2/apache2.conf
      - file: /etc/apache2/conf-available/security.conf
      - file: /etc/apache2/mods-available/ssl.conf
      - file: /etc/apache2/sites-available/default-ssl.conf
      - file: /etc/ssl/certs/cert.pem
      - file: /etc/ssl/certs/chain.pem
      - file: /etc/ssl/private/key.pem
    - require:
      - file: /var/log/httpd_site_logs
      - cmd: apache-enable-default-ssl-site
