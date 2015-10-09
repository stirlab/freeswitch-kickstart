{% from 'vars.jinja' import server_env with context -%}

# TODO: For now this is always disabled. It can be enabled for production when
# we start deploying mulitple servers via Salt.
{% set service_status = 'disabled' %}

salt-minion-service:
  service.{{ service_status }}:
    - name: salt-minion
