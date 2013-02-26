Mongoid Geospatial
==================

A Mongoid Extension that simplifies the use of MongoDB spatial features.

** On beta again **

Removing some trash, improving and adding support for RGeo and GeoRuby.
Version 2+ is going to be beta testing, when it's ready I'll release v3,
So the major version stays the same as mongoid.


There are no plans to support MongoDB < 2.0
There are no plans to support Mongoid <= 2.0


Quick Start
-----------

This gem focus on (making helpers for) spatial features MongoDB has.
You can also use an external Geometric/Spatial alongside.

    # Gemfile
    gem 'mongoid_geospatial'

    # A place to illustrate Point, Line and Polygon
    class Place
      include Mongoid::Document

      # Include the module
      include Mongoid::Geospatial

      # Just like mongoid,
      field :name,     type: String
      # define your field, but choose a geometry type:
      field :location, type: Point
      field :route,    type: Linestring
      field :area,     type: Polygon

      # If your are going to query on your points, don't forget to index:
      spatial_index :location
      # You can index points with :spatial => true option too, see below.
    end


For geo points, an extra macro `geo_field` is available


    class Place
      include Mongoid::Document
      include Mongoid::Geospatial
      
      # field :location, type: Point, spatial: true
      geo_field :location
    end


Generate indexes on MongoDB:


    rake db:mongoid:create_indexes


Index programatically via https://github.com/kristianmandrup/mongoid_indexing gem


    Mongoid::Indexing.create_indexes


This is fx useful when running specs or when working with spatials on a gem or engine.


Points
------

Currently, MongoDB supports query operations on 2D points only, so that's
what this lib does. All geometries apart from points are just arrays
in the database. Here's is how you can input a point as:

* longitude latitude array in that order - [long,lat] ([x, y])
* an unordered hash with latitude key(:lat, :latitude) and a longitude key(:lon, :long, :lng, :longitude)
* an ordered hash with longitude as the first item and latitude as the second item
  This hash does not have include the latitude and longitude keys
  \*only works in ruby 1.9 and up because hashes below ruby 1.9 because they are not ordered
* anything with the a method #to_xy or #to_lng_lat that converts itself to  [long, lat] array

We store data in the DB as a [x, y] array then reformat when it is returned to you


    hudson = River.create(
      name: 'Hudson',
      length: 315,
      discharge: 21_400,
      # when setting array LNG (x) MUST BE FIRST LAT (y) MUST BE SECOND
      # source: [-73.935833,44.106667],
      # but we can use hash in any order
      source: {:lat => 44.106667, :lng => -73.935833},
      mouth: {:latitude => 40.703056, :longitude => -74.026667}

Now to access this spatial information we can do this

    hudson.mouth  # => [-74.026667, 40.703056]

If you need a hash

    hudson.mouth.to_hsh  # => { x: -74.026667, y: 40.703056 }

If you are using GeoRuby or RGeo

    hudson.mouth.to_geo  # => NiceGeolib::Point

Conventions: This lib uses #x and #y everywhere. 1. It's shorter than lat or lng or another variation that also confuses. 2. A point is a 2D mathematical notation, longitude/latitude is when you use that notation to map an sphere. In other words, all longitudes are 'xs' where not all 'xs' are longitudes. In the eyes of a moralist it's not even a valid position point, it does not have #z or #m.

Distance and other geometrical calculations are delegated to the external
library you choosed. More info about using RGeo or GeoRuby below.
Some built in helpers for mongoid queries:

    # Returns middle point + radius
    # Useful to search #within_circle
    hudson.mouth.radius(5)        # [[-74.., 40..], 5]
    hudson.mouth.radius_sphere(5) # [[-74.., 40..], 0.00048..]

    # Returns hash if needed
    hudson.mounth.to_hsh              # {:x => -74.., :y => 40..}
    hudson.mounth.to_hsh(:lon, :lat)  # {:lon => -74.., :lat => 40..}


And for polygons and lines:

    house.area.bbox    # Returns polygon bounding_box (envelope)
    house.area.center  # Returns calculate middle point


Query
-----

Before you read about mongoid_spatial have sure you read this:

http://mongoid.org/en/origin/docs/selection.html#standard

All MongoDB queries are handled by Mongoid.


You can use Geometry instance directly on any query:

* near
  * Bar.near(location: person.house)
  * Bar.where(:location.near => person.house)


* near_sphere
  * Bar.near_sphere(location: person.house)
  * Bar.where(:location.near_sphere => person.house)


* within_box
  * Bar.within_box(location: hood.area)


* within_circle
  * Bar.within_circle(location: hood.area)


* within_circle_sphere
  * Bar.within_circle_sphere(location: hood.area)


* within_polygon
  * Bar.within_polygon(location: city.area)


External Libraries
------------------

Use RGeo?
https://github.com/dazuma/rgeo

RGeo is a Ruby wrapper for Proj/GEOS.
It's perfect when you need to work with complex calculations and projections.
It'll require more stuff installed to compile/work.


Use GeoRuby?
https://github.com/nofxx/geo_ruby

GeoRuby is a pure Ruby Geometry Library.
It's perfect if you want simple calculations and/or keep your stack in pure ruby.
Albeit not full featured in maths it has a handful of methods and good import/export helpers.

Use Nothing?

This lib won't stand in your way.
Write your own wrapper if you want.


Geometry Helpers
----------------

We currently support GeoRuby and RGeo.
If you require one of those, a #to_geo method will be available to all
spatial fields, returning the external library corresponding object.
To illustrate:

    class Person
      include Mongoid::Document
      include Mongoid::Geospatial

      field :location, type: Point
    end

    me = Person.new(location: [8, 8])

    # Example with GeoRuby
    point.class # Mongoid::Geospatial::Point
    point.to_geo.class # GeoRuby::SimpleFeatures::Point

    # Example with RGeo
    point.class # Mongoid::Geospatial::Point
    point.to_geo.class # RGeo::Geographic::SphericalPointImpl


Configure
---------

Assemble it as you need (use a initializer file):

With RGeo

    Mongoid::Geospatial.use_rgeo
    # Optional
    # Mongoid::Geospatial.factory = RGeo::Geographic.spherical_factory


With GeoRuby

    Mongoid::Geospatial.use_georuby


Defaults (change if you know what you're doing)

    Mongoid::Geospatial.lng_symbol = :x
    Mongoid::Geospatial.lat_symbol = :y
    Mongoid::Geospatial.earth_radius = EARTH_RADIUS



Model Setup
-----------

You can create Point, Line, Circle, Box and Polygon on your models:


    class CrazyGeom
      include Mongoid::Document
      include Mongoid::Geospatial

      field :location,  type: Point, :spatial => true, :delegate => true

      field :route,     type: Line
      field :area,      type: Polygon

      field :square,    type: Box
      field :around,    type: Circle

      # spatial indexing
      spatial_index :mouth

      # default mongodb options
      spatial_index :mouth, {bit: 24, min: -180, max: 180}

      # query by location
      spatial_scope :location
    end


Helpers
-------

You can use `:spatial => true` to add an '2d' index automatically,
No need for `spatial_index :location`:


    field :location,  type: Point, :spatial => true


You can delegate some point methods to the instance itself:


    field :location,  type: Point, :delegate => true


Now instead of `instance.location.x` you may call `instance.x`.


Nearby
------

You can add a `spatial_scope` on your models. So you can query:

    Bar.nearby(my.location)

instead of

    Bar.near(location: my.location)

Good when you're drunk. Just add to your model:

    spatial_scope :<field>



Geometry
--------

You can also store Circle, Box, Line (LineString) and Polygons.
Some helper methods are available to them:


    # Returns a geometry bounding box
    # Useful to query #within_box
    polygon.bbox
    polygon.bounding_box

    # Returns a geometry calculated middle point
    # Useful to query for #near
    polygon.center

    # Returns middle point + radius
    # Useful to search #within_circle
    polygon.radius(5)        # [[1.0, 1.0], 5]
    polygon.radius_sphere(5) # [[1.0, 1.0], 0.00048..]




Mongo DB 1.9+ New Geo features
---------

Multi-location Documents v.1.9+

MongoDB now also supports indexing documents by multiple locations. These locations can be specified in arrays of sub-objects, for example:

```
> db.places.insert({ addresses : [ { name : "Home", loc : [55.5, 42.3] }, { name : "Work", loc : [32.3, 44.2] } ] })
> db.places.ensureIndex({ "addresses.loc" : "2d" })
```

Multiple locations may also be specified in a single field:

```
> db.places.insert({ lastSeenAt : [ { x : 45.3, y : 32.2 }, [54.2, 32.3], { lon : 44.2, lat : 38.2 } ] })
> db.places.ensureIndex({ "lastSeenAt" : "2d" })
```

By default, when performing geoNear or $near-type queries on collections containing multi-location documents, the same document may be returned multiple times, since $near queries return ordered results by distance. Queries using the $within operator by default do not return duplicate documents.

  v2.0
In v2.0, this default can be overridden by the use of a $uniqueDocs parameter for geoNear and $within queries, like so:

```
> db.runCommand( { geoNear : "places" , near : [50,50], num : 10, uniqueDocs : false } )
> db.places.find( { loc : { $within : { $center : [[0.5, 0.5], 20], $uniqueDocs : true } } } )
```

  Currently it is not possible to specify $uniqueDocs for $near queries
Whether or not uniqueDocs is true, when using a limit the limit is applied (as is normally the case) to the number of results returned (and not to the docs or locations).  If running a geoNear query with uniqueDocs : true, the closest location in a document to the center of the search region will always be returned - this is not true for $within queries.

In addition, when using geoNear queries and multi-location documents, often it is useful to return not only distances, but also the location in the document which was used to generate the distance.  In v2.0, to return the location alongside the distance in the geoNear results (in the field loc), specify includeLocs : true in the geoNear query. The location returned will be a copy of the location in the document used.

  If the location was an array, the location returned will be an object with "0" and "1" fields in v2.0.0 and v2.0.1.

```
> db.runCommand({ geoNear : "places", near : [ 0, 0 ], maxDistance : 20, includeLocs : true })
{
  "ns" : "test.places",
  "near" : "1100000000000000000000000000000000000000000000000000",
  "results" : [
    {
      "dis" : 5.830951894845301,
      "loc" : {
        "x" : 3,
        "y" : 5
      },
      "obj" : {
        "_id" : ObjectId("4e52672c15f59224bdb2544d"),
        "name" : "Final Place",
        "loc" : {
          "x" : 3,
          "y" : 5
        }
      }
    },
    {
      "dis" : 14.142135623730951,
      "loc" : {
        "0" : 10,
        "1" : 10
      },
      "obj" : {
        "_id" : ObjectId("4e5266a915f59224bdb2544b"),
        "name" : "Some Place",
        "loc" : [
          [
            10,
            10
          ],
          [
            50,
            50
          ]
        ]
      }
    },
    {
      "dis" : 14.142135623730951,
      "loc" : {
        "0" : -10,
        "1" : -10
      },
      "obj" : {
        "_id" : ObjectId("4e5266ba15f59224bdb2544c"),
        "name" : "Another Place",
        "loc" : [
          [
            -10,
            -10
          ],
          [
            -50,
            -50
          ]
        ]
      }
    }
  ],
  "stats" : {
    "time" : 0,
    "btreelocs" : 0,
    "nscanned" : 5,
    "objectsLoaded" : 3,
    "avgDistance" : 11.371741047435734,
    "maxDistance" : 14.142157540259815
  },
  "ok" : 1
}
```

The plan is to include this functionality in a future release. Please help out ;)

This Fork
---------

This fork is not backwards compatible with 'mongoid_spatial'.
This fork delegates calculations to the external libs and use Moped.

Change in your models:

    include Mongoid::Spacial::Document

to

    include Mongoid::Geospatial


And for the fields:


    field :source,  type: Array,    spacial: true

to

    field :source,  type: Point,    spatial: true


Beware the 't' and 'c' issue. It's spaTial.



Troubleshooting
---------------

**Mongo::OperationFailure: can't find special index: 2d**

Indexes need to be created. Execute command:

    rake db:mongoid:create_indexes

Using mongoid_geospatial (or mongoid for that matter) without rails?

    https://github.com/kristianmandrup/mongoid_indexing

You need a way to create indexes easily, check out the gem above.


Thanks
------

* Thanks to Kristian Mandrup for creating the base of the gem and a few of the tests
* Thanks to CarZen LLC. for letting me release the code we are using


Contributing
------------

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.


Copyright
-----------

WTFPL

http://en.wikipedia.org/wiki/WTFPL
