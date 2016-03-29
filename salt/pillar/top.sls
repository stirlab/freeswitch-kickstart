base:
  '*':
    - server.common
    - ignore_missing: True
  # This allows extending the Salt configuration for different environments.
  'server:env:development':
    - match: grain
    - server.development
  'server:env:production':
    - match: grain
    - server.production

