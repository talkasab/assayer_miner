# Include path
GEM_LIB = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift GEM_LIB unless $LOAD_PATH.include?(GEM_LIB)

# Requirements
require 'rubygems'
require 'yaml'
require 'assayer_miner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["spec/support/**/*.rb"].each {|f| require f}

# Configure RSpec
RSpec.configure do |config|
  config.mock_with :rspec
end

# Set up AssayerMiner
config_file = File.join(File.dirname(__FILE__), 'support', 'config.yml')
CONFIG_OPTS = YAML.load_file(config_file)
AssayerMiner.load_configuration(config_file)
