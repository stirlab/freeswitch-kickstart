{% from 'vars.jinja' import
  freeswitch_git_checkout,
  nginx_http_port,
  nginx_https_port,
  server_env,
  server_id,
  www_domain,
with context %}

include:
  - misc.ssl

nginx-package:
  pkg.installed:
    - name: nginx

nginx-user:
  user.present:
    - name: www-data
    - groups:
      - ssl
    - require:
      - pkg: nginx-package
      - group: ssl-group

nginx.conf-server_names_hash_bucket_size:
  file.replace:
    - name: /etc/nginx/nginx.conf
    - pattern: '# server_names_hash_bucket_size \d+;$'
    - repl: "server_names_hash_bucket_size 128;"
    - require:
      - pkg: nginx-package

/etc/nginx/sites-available/default:
  file.absent:
    - require:
      - pkg: nginx-package

/etc/nginx/conf.d/verto.conf:
  file.managed:
    - template: jinja
    - context:
      freeswitch_git_checkout: {{ freeswitch_git_checkout }}
      nginx_http_port: {{ nginx_http_port }}
      nginx_https_port: {{ nginx_https_port }}
      server_env: {{ server_env }}
      server_id: {{ server_id }}
      www_domain: {{ www_domain }}
    - source: salt://service/nginx/verto.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: nginx-package

nginx-service:
  service.running:
    - name: nginx
    - enable: true
    - require:
      - user: nginx-user
      - file: nginx.conf-server_names_hash_bucket_size
    - watch:
      - pkg: nginx-package
      - file: /etc/ssl/private/key.pem
      - file: build-chain-bundle.pem
      - file: /etc/nginx/sites-available/default
      - file: /etc/nginx/conf.d/verto.conf
