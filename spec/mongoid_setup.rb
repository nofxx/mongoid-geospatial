module Mongoid
  module VersionSetup
    def self.configure config
      version = Mongoid::VERSION
      case
      when version < '2'
        raise ArgumentError, "Mongoid versions < 2 not supported"
      when version < '3'
        version_2 config
      when version > '3'
        version_3 config
      end
    end

    def self.version_3 config
      config.connect_to('mongoid_geo_test')
    end

    def self.version_2 config
      opts = YAML.load(File.read(File.dirname(__FILE__) + '/support/mongoid.yml'))["test"]
      opts.delete("slaves") # no slaves support for version < 3
      name = opts.delete("database")
      host = opts.delete("host")
      port = opts.delete("port")
      config.master = begin
         Mongo::Connection.new(host, port, opts).db(name)
      rescue Mongo::ConnectionFailure
        Mongo::Connection.new(host, '27017', opts).db(name)
      end
      config.logger = nil
      config.allow_dynamic_fields = true
    end      
  end
end