# Include path
GEM_LIB = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift GEM_LIB unless $LOAD_PATH.include?(GEM_LIB)

# Requirements
require 'rubygems'
require 'yaml'
require 'scenario_extractor'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["spec/support/**/*.rb"].each {|f| require f}

# Configure RSpec
RSpec.configure do |config|
  config.mock_with :rspec
end

# Set up ScenarioExtractor
CONFIG_OPTS = YAML.load_file(File.join(File.dirname(__FILE__), 'support', 'config.yml'))
ScenarioExtractor.configure_qpid(CONFIG_OPTS)
