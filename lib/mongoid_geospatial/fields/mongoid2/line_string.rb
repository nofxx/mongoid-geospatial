module Mongoid
  module Geospatial
    class LineString
      include Mongoid::Fields::Serializable

      def self.instantiate name, options = {}
        super
      end

      def serialize(object)
        object.to_a
      end

      def deserialize(object)
        return unless object && !object.empty?
        RGeo::Geographic.spherical_factory.line_string(*object)
      end
    end
  end
end
