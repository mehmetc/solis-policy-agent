module Sinatra
  module MainHelper
    def opa_config
      ConfigFile[:services][:policy_agent]
    end
  end
  helpers MainHelper
end