require "spec_helper"

describe Mongoid::Geospatial::Line do

  describe "(de)mongoize" do

    it "should support a field mapped as linestring" do
      river = River.new(source: [[5,5],[6,5],[6,6],[5,6]])
      river.source.should be_a Mongoid::Geospatial::Line
      river.source.should eq([[5,5],[6,5],[6,6],[5,6]])
    end

    it "should support a field mapped as linestring" do
      River.create!(source: [[5,5],[6,5],[6,6],[5,6]])
      River.first.source.should eq([[5,5],[6,5],[6,6],[5,6]])
    end

    it "should have a bounding box" do
      geom = Mongoid::Geospatial::Line.new [[1,5],[6,5],[6,6],[5,6]]
      geom.bbox.should eq([[1,5], [6,6]])
    end

    it "should have a center point" do
      geom = Mongoid::Geospatial::Line.new [[1,1],[1,1],[9,9],[9,9]]
      geom.center.should eq([5.0,5.0])
    end

    it "should have a radius helper" do
      geom = Mongoid::Geospatial::Line.new [[1,1],[1,1],[9,9],[9,9]]
      geom.radius(10).should eq([[5.0,5.0], 10])
    end

    it "should have a radius sphere" do
      geom = Mongoid::Geospatial::Line.new [[1,1],[1,1],[9,9],[9,9]]
      geom.radius_sphere(10)[1].should be_within(0.001).of(0.001569)
    end

  end

end
