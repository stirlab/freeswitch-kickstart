include:
  - service.httpd

demo-vid-archive:
  archive.extracted:
    - name: /var/www/html/
    - source: http://demo.freeswitch.org/vid.tgz
    - source_hash: md5=b66e55c954d10b2bc7e39e834efa224a
    - archive_format: tar
    - user: root
    - group: root
    - if_missing: /var/www/html/vid/

demo-symlink-vid-html:
  file.symlink:
    - name: /var/www/vid
    - target: /var/www/html/vid
    - require:
      - archive: demo-vid-archive
      - pkg: httpd-packages

