# config/initializers/cors.rb
# ref: https://github.com/cyu/rack-cors

# font cors issue with CDN
# Ref: https://stackoverflow.com/questions/56960709/rails-font-cors-policy
# Which origins the browser may call us from. ALLOWED_ORIGINS still wins when it is
# set. When it is not, the host comes from FRONTEND_URL, so the allowlist follows the
# deployment instead of a domain written down here that quietly goes stale.
cw_frontend_host = begin
  URI.parse(ENV.fetch('FRONTEND_URL', '').to_s).host
rescue URI::InvalidURIError
  nil
end

cw_allowed_origins = ENV
                     .fetch('ALLOWED_ORIGINS') { cw_frontend_host.presence || 'localhost' }
                     .split(',').map { |origin| origin.strip.sub(%r{\A\w+://}, '') }.reject(&:empty?)
cw_allowed_origins = ['localhost'] if cw_allowed_origins.empty?

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allowed_origins = cw_allowed_origins

    origins(*allowed_origins)

    resource '/packs/*', headers: :any, methods: [:get, :options]
    resource '/audio/*', headers: :any, methods: [:get, :options]
    # Make the public endpoints accessible to the frontend
    resource '/public/api/*', headers: %w[Content-Type Authorization], methods: [:get, :post, :options]

    if ActiveModel::Type::Boolean.new.cast(ENV.fetch('CW_API_ONLY_SERVER', false)) || Rails.env.development?
      origins(*allowed_origins, 'localhost', /127\.0\.0\.1/)
      resource '*', headers: %w[Content-Type Authorization X-Auth-Token], methods: :any, expose: %w[access-token client uid expiry]
    end

    if ActiveModel::Type::Boolean.new.cast(ENV.fetch('ENABLE_API_CORS', false))
      resource '/api/*', headers: %w[Content-Type Authorization X-Auth-Token], methods: :any, expose: %w[access-token client uid expiry]
    end
  end
end

################################################
######### Action Cable Related Config ##########
################################################

# Mount Action Cable outside main process or domain
# Rails.application.config.action_cable.mount_path = nil
# Rails.application.config.action_cable.url = 'wss://example.com/cable'

# Action Cable - configurar orígenes permitidos en vez de deshabilitar forgery protection
# Same list, as full origins. The scheme is stripped above, so a value that already
# carries one does not end up as https://https://host.
Rails.application.config.action_cable.allowed_request_origins = cw_allowed_origins.map { |origin| "https://#{origin}" }
