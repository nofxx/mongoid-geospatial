module Mongoid
  module Geospatial
    class LineString
      # See http://mongoid.org/en/mongoid/docs/upgrading.html

      def mongoize
        to_a
      end

      class << self
        def demongoize(object)
          RGeo::Geographic.spherical_factory.line_string *object
        end

        # def evolve(object)
        #   { "$gte" => object.first, "$lte" => object.last }
        # end
      end
    end
  end
end
