require "spec_helper"

describe "RGeo Wrapper" do

  before(:all) do
    Mongoid::Geospatial.send(:remove_const, 'Point')
    Mongoid::Geospatial.send(:remove_const, 'Polygon')
    Mongoid::Geospatial.send(:remove_const, 'Line')

    load "#{File.dirname(__FILE__)}/../../../lib/mongoid_geospatial/fields/point.rb"
    load "#{File.dirname(__FILE__)}/../../../lib/mongoid_geospatial/fields/polygon.rb"
    load "#{File.dirname(__FILE__)}/../../../lib/mongoid_geospatial/fields/line.rb"

    Object.send(:remove_const, 'Bar')
    load "#{File.dirname(__FILE__)}/../../models/bar.rb"

    Object.send(:remove_const, 'Farm')
    load "#{File.dirname(__FILE__)}/../../models/farm.rb"

    Object.send(:remove_const, 'River')
    load "#{File.dirname(__FILE__)}/../../models/river.rb"
  end

  describe Mongoid::Geospatial::Point do
    it "should not interfer with mongoid" do
      Bar.create!(name: "Moe's")
      Bar.count.should eql(1)
    end

    it "should not respond to distance before loading external" do
      bar = Bar.create!(location: [5,5])
      bar.location.should_not respond_to(:distance)
    end
  end

  describe Mongoid::Geospatial::Polygon do
    it "should not interfer with mongoid" do
      Farm.create!(name: "Springfield Nuclear Power Plant")
      Farm.count.should eql(1)
    end

    it "should not respond to to_geo before loading external" do
      farm = Farm.create!(area: [[5,5],[6,5],[6,6],[5,6]])
      farm.area.should_not respond_to(:to_geo)
    end
  end

  describe Mongoid::Geospatial::Line do
    it "should not interfer with mongoid" do
      River.create!(name: "Mississippi")
      River.count.should eql(1)
    end

    it "should not respond to to_geo before loading external" do
      river = River.create!(source: [[5,5],[6,5],[6,6],[5,6]])
      river.source.should_not respond_to(:to_geo)
    end
  end

  describe "queryable" do

    before do
      Mongoid::Geospatial.use_rgeo
      Bar.create_indexes
      Farm.create_indexes
      River.create_indexes
    end

    describe "(de)mongoize" do

      describe Mongoid::Geospatial::Point do
        it "should mongoize array" do
          geom = Bar.new(location: [10, -9]).location
          geom.class.should eql(Mongoid::Geospatial::Point)
          geom.to_geo.class.should eql(RGeo::Geographic::SphericalPointImpl)
          geom.x.should be_within(0.1).of(10)
          geom.to_geo.y.should be_within(0.1).of(-9)
        end

        it "should mongoize hash" do
          geom = Bar.new(location: {x: 10, y: -9}).location
          geom.class.should eql(Mongoid::Geospatial::Point)
          geom.to_geo.class.should eql(RGeo::Geographic::SphericalPointImpl)
        end

        it "should accept an RGeo object" do
          point = RGeo::Geographic.spherical_factory.point 1, 2
          bar = Bar.create!(location: point)
          bar.location.x.should be_within(0.1).of(1)
          bar.location.y.should be_within(0.1).of(2)
        end

        it "should calculate 3d distances by default" do
          bar = Bar.create! location: [-73.77694444, 40.63861111 ]
          bar2 = Bar.create! location: [-118.40, 33.94] #,:unit=>:mi, :spherical => true)
          bar.location.distance(bar2.location).to_i.should be_within(1).of(3978262)
        end
      end

      describe Mongoid::Geospatial::Polygon do
        it "should mongoize array" do
          geom = Farm.create!(area: [[5,5],[6,5],[6,6],[5,6]]).area
          geom.class.should eql(Mongoid::Geospatial::Polygon)
          geom.to_geo.class.should eql(RGeo::Geographic::SphericalPolygonImpl)
          geom.to_geo.to_s.should eq "POLYGON ((5.0 5.0, 6.0 5.0, 6.0 6.0, 5.0 6.0, 5.0 5.0))"
        end
      end

      describe Mongoid::Geospatial::Line do
        it "should mongoize array" do
          geom = River.create!(source: [[5,5],[6,5],[6,6],[5,6]]).source
          geom.class.should eql(Mongoid::Geospatial::Line)
          geom.to_geo.class.should eql(RGeo::Geographic::SphericalLineStringImpl)
          geom.to_geo.to_s.should eq "LINESTRING (5.0 5.0, 6.0 5.0, 6.0 6.0, 5.0 6.0)"
        end
      end
    end
  end
end
