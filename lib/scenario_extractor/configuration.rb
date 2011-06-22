require 'qpid'
require 'yaml'
require 'tiny_tds'

module ScenarioExtractor
  class << self

    def load_configuration(filename='config.yml')
      all_config = YAML.load_file(filename)
      configure_ris_db(all_config[:ris_db]) if all_config[:ris_db].present?
      configure_qpid(all_config[:qpid]) if all_config[:qpid].present?
    end

    def configure_ris_db(opts={})
      @ris_db_client = TinyTds::Client.new(opts)
    end

    def ris_db_client; @ris_db_client; end

    def configure_qpid(opts = {})
      @qpid = Qpid.new(opts)
    end

    def qpid; @qpid; end
  end  
end
