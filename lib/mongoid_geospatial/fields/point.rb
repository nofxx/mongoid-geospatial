module Mongoid
  module Geospatial
    class Point
      attr_accessor :x, :y

      def initialize(x, y)
        @x, @y = x, y
      end

      # Object -> Database
      def mongoize
        [x, y]
      end
      alias :to_a  :mongoize
      alias :to_xy :mongoize

      def [](args)
        mongoize[args]
      end

      class << self

        # Database -> Object
        def demongoize(object)
          Point.new(object[0], object[1]) rescue nil
        end

        def mongoize(object)
          case object
          when Point then object.mongoize
          when Array then object.to_xy
          when Hash then object.to_xy
          else object
          end
        end

        # Converts the object that was supplied to a criteria
        # into a database friendly form.
        def evolve(object)
          object.respond_to?(:x) ? object.mongoize : object
        end
      end

    end
  end
end
