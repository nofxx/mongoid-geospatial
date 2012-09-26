module Mongoid
  module Geospatial
    extend ActiveSupport::Concern

    LNG_SYMBOLS = [:x, :lon, :long, :lng, :longitude]
    LAT_SYMBOLS = [:y, :lat, :latitude]

    EARTH_RADIUS_KM = 6371 # taken directly from mongodb
    RAD_PER_DEG = Math::PI / 180

    EARTH_RADIUS = {
      :km => EARTH_RADIUS_KM,
      :m  => EARTH_RADIUS_KM * 1000,
      :mi => EARTH_RADIUS_KM * 0.621371192, # taken directly from mongodb
      :ft => EARTH_RADIUS_KM * 5280*0.621371192,
      :sm => EARTH_RADIUS_KM * 0.53995680345572 # sea mile
    }

    mattr_accessor :lng_symbols
    mattr_accessor :lat_symbols
    mattr_accessor :earth_radius
    mattr_accessor :factory

    @@lng_symbols  = LNG_SYMBOLS.dup
    @@lat_symbols  = LAT_SYMBOLS.dup
    @@earth_radius = EARTH_RADIUS.dup

    included do
      # attr_accessor :geo
      cattr_accessor :spatial_fields, :spatial_fields_indexed
      self.spatial_fields = []
      self.spatial_fields_indexed = []
    end

    def self.use_rgeo
      require 'mongoid_geospatial/wrappers/rgeo'
    end

    def self.use_georuby
      require 'mongoid_geospatial/wrappers/georuby'
    end

    module ClassMethods #:nodoc:

      # create spatial index for given field
      # @param [String,Symbol] name
      # @param [Hash] options options for spatial_index
      # http://www.mongodb.org/display/DOCS/Geospatial+Indexing#GeospatialIndexing-geoNearCommand
      def spatial_index name, options = {}
        self.spatial_fields_indexed << name
        index({name => '2d'}, options)
      end

      def spatial_scope field, opts = {}
        self.singleton_class.class_eval do
          # define_method(:close) do |args|
          define_method(:nearby) do |args|
            queryable.where(field.near_sphere => args)
          end
        end
      end

    end

  end
end
