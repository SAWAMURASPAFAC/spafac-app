Rails.application.configure do
  config.force_ssl = true
  config.cache_classes = true

  config.eager_load = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  config.cache_store = :dalli_store,
    (ENV["MEMCACHIER_SERVERS"] || "").split(","),
    {:username => ENV["MEMCACHIER_USERNAME"],
     :password => ENV["MEMCACHIER_PASSWORD"],
     :failover => true,
     :socket_timeout => 1.5,
     :socket_failure_delay => 0.2
    }

  config.action_dispatch.rack_cache = true
  config.middleware.use Rack::Cache,
                        :verbose => true,
                        :metastore   => 'file:/var/cache/rack/meta',
                        :entitystore => 'file:/var/cache/rack/body'

  client = Dalli::Client.new((ENV["MEMCACHIER_SERVERS"] || "").split(","),
                             :username => ENV["MEMCACHIER_USERNAME"],
                             :password => ENV["MEMCACHIER_PASSWORD"],
                             :failover => true,
                             :socket_timeout => 1.5,
                             :socket_failure_delay => 0.2,
                             :value_max_bytes => 10485760)
  config.action_dispatch.rack_cache = {
    :metastore    => client,
    :entitystore  => client
  }
  config.static_cache_control = "public, max-age=2592000"

  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  config.assets.compile = false
  config.assets.digest = true
  config.assets.compress = true
  config.assets.debug = false

  config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.log_level = :debug

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.autoflush_log = false

  config.log_formatter = ::Logger::Formatter.new

  config.active_record.dump_schema_after_migration = false

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  config.action_mailer.default_url_options = { host: "#{ENV['HEROKU_APP_NAME']}.herokuapp.com" }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => "heroku.com",
    :address        => "smtp.sendgrid.net",
    :port           => 25, # ssl:587, plain:25
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end
