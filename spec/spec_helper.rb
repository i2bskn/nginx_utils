require "simplecov"
require "coveralls"
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter "spec"
  add_filter ".bundle"
end

require "nginx_utils"

support_files = File.join(File.expand_path("..", __FILE__), "support/*.rb")
Dir[support_files].each {|f| require f}

RSpec.configure do |config|
  config.order = "random"
  config.include(SpecUtils)
end
