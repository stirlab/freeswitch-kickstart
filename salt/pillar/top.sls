base:
  # This allows extending the Salt configuration for different environments.
  'server:env:development':
    - match: grain
    - server.development

