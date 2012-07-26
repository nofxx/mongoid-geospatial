module Mongoid
  module Geospatial
    class Polygon
      # See http://mongoid.org/en/mongoid/docs/upgrading.html

      def mongoize
        self #.flatten
      end

      class << self
        def demongoize(object)
          points = object.map do |pair|
            RGeo::Geographic.spherical_factory.point *pair
          end
          ring = RGeo::Geographic.spherical_factory.linear_ring points
          RGeo::Geographic.spherical_factory.polygon ring
        end

        # def evolve(object)
        #   { "$gte" => object.first, "$lte" => object.last }
        # end
      end
    end
  end
end
