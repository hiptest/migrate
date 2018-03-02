require './lib/models/test_snapshot'

RSpec.configure do |config|
  config.before do
    ENV['ZEPHYR_POC_SILENT'] = "1"
    ENV['HT_URI'] = "https://hiptest.net/api"
    API::Hiptest.base_url = "https://hiptest.net/api"
    API::Hiptest.use_ssl = true
    Models::TestSnapshot.class_variable_set(:@@pushed_results, [])
  end
end
