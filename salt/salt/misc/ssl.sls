{% from 'vars.jinja' import
  server_ssl_cert,
  server_ssl_chain,
  server_ssl_key,
  server_type,
with context %}

ssl-group:
  group.present:
    - name: ssl
    - system: True

/etc/ssl/certs/cert.pem:
  file.managed:
    - source: salt://etc/ssl/{{ server_ssl_cert }}
    - user: root
    - group: root
    - mode: 644

/etc/ssl/certs/chain.pem:
  file.managed:
    - source: salt://etc/ssl/{{ server_ssl_chain }}
    - user: root
    - group: root
    - mode: 644

/etc/ssl/private/key.pem:
  file.managed:
    - source: salt://etc/ssl/{{ server_ssl_key }}
    - user: root
    - group: ssl
    - mode: 640
    - require:
      - group: ssl-group

clean-ssl-bundle-cert:
  cmd.run:
    - name: rm -f chain-bundle.pem
    - cwd: /etc/ssl/certs
    - onchanges:
      - file: /etc/ssl/certs/cert.pem
      - file: /etc/ssl/certs/chain.pem

# Alternate state name required to avoid 'Recursive requisite found' error.
Add /etc/ssl/certs/chain-bundle.pem:
  file.managed:
    - name: /etc/ssl/certs/chain-bundle.pem
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: clean-ssl-bundle-cert

build-chain-bundle.pem:
  file.append:
    - name: /etc/ssl/certs/chain-bundle.pem
    - sources:
      - salt://etc/ssl/{{ server_ssl_cert }}
      - salt://etc/ssl/{{ server_ssl_key }}
    - require:
      - file: Add /etc/ssl/certs/chain-bundle.pem

{% if server_type == 'vagrant' %}

/usr/local/share/ca-certificates/stirlab:
  file.directory:
    - user: root
    - group: root

/usr/local/share/ca-certificates/stirlab/stirlab-local-ca.crt:
  file.managed:
    - source: salt://etc/ssl/stirlab-local-ca.crt
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /usr/local/share/ca-certificates/stirlab

install-stirlab-local-ca.crt:
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
    - onchanges:
      - file: /usr/local/share/ca-certificates/stirlab/stirlab-local-ca.crt
{% endif %}
