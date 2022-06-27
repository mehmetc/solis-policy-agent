$LOAD_PATH << '.'
raise 'Please set SERVICE_ROLE environment parameter' unless ENV.include?('SERVICE_ROLE')
$SERVICE_ROLE=ENV['SERVICE_ROLE'].downcase.to_sym
puts "setting SERVICE_ROLE=#{$SERVICE_ROLE}"

require 'logger'
require 'app/controllers/main_controller'

LOGGER=Logger.new(STDOUT)

map "#{ConfigFile[:services][$SERVICE_ROLE][:base_path]}" do
  LOGGER.info("Mounting 'MainController' on #{ConfigFile[:services][$SERVICE_ROLE][:base_path]}")
  run MainController
end

# docker-compose exec opa build --bundle --output /policies/archiefpunt.tar.gz ./policies/archiefpunt.rego --capabilities v0.22.0