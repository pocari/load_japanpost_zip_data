require 'singleton'

class ConfigHelper
  include Singleton
  def initialize
    @config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/../config/config.yaml"))
  end

  def [](keys)
    keys.inject(nil) do |acc, key|
      (acc || @config)[key.to_s]
    end
  end

  class << self
    def [](*keys)
      instance[keys]
    end
  end
end
