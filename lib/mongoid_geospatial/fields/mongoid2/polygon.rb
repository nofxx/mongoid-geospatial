module Mongoid
  module Geospatial
    class Polygon
      include Mongoid::Fields::Serializable

      def self.instantiate name, options = {}
        super
      end

      def serialize(object)
        object
      end

      def deserialize(object)
        points = object.map do |pair|
          RGeo::Geographic.spherical_factory.point *pair
        end
        ring = RGeo::Geographic.spherical_factory.linear_ring points
        RGeo::Geographic.spherical_factory.polygon ring
      end
    end
  end
end
