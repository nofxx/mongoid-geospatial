module Mongoid
  module Geospatial
    class Point
      include Mongoid::Fields::Serializable

      def self.instantiate name, options = {}
        super
      end

      def serialize(object)
        object.respond_to?(:x) ? [object.x, object.y] : object
      end

      def deserialize(object)
        return unless object && !object.empty?
        RGeo::Geographic.spherical_factory.point *object
      end
    end
  end
end