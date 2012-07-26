require "spec_helper"

describe Mongoid::Geospatial do

  it "should instantiate with no problems" do
    Bar.create!(name: "Moe's")
    Bar.count.should eql(1)
  end

  it "should have a field mapped as point" do
    bar = Bar.create!(location: [5,5])
    bar.location.should be_a RGeo::Geographic::SphericalPointImpl
  end

  it "should have a .to_a" do
    bar = Bar.create!(location: [3,2])
    bar.location.to_a[0..1].should == [3.0, 2.0]
  end

  it "should have an array [] accessor" do
    bar = Bar.create!(location: [3,2])
    bar.location[0].should == 3.0
  end


  it "should accept an RGeo object" do
    point = RGeo::Geographic.spherical_factory.point 1, 2
    bar = Bar.create!(location: point)
    bar.location.x.should be_within(0.1).of(1)
    bar.location.y.should be_within(0.1).of(2)
  end

  it "should calculate distance between points" do
    bar = Bar.create!(location: [5,5])
    bar2 = Bar.create!(location: [15,15])
    bar.location.distance(bar2.location).should be_within(1).of(1561283.8)
  end

  it "should calculate distance between points miles" do
    pending
    bar = Bar.create!(location: [5,5])
    bar2 = Bar.create!(location: [15,15])
    bar.location.distance(bar2.location).should be_within(1).of(1561283.8)
  end

  it "should calculate 3d distances by default" do
    bar = Bar.create! location: [-73.77694444, 40.63861111 ]
    bar2 = Bar.create! location: [-118.40, 33.94] #,:unit=>:mi, :spherical => true)
    bar.location.distance(bar2.location).to_i.should be_within(1).of(2469)
  end

  it "should have a nice simple way to ovewrite geo factory" do
    pending
    bar = Bar.create!(location: [5,5])
    bar2 = Bar.create!(location: [15,15])
    bar.location.distance(bar2.location).should be_within(1).of(1561283.8)
  end

  it "should have a field mapped as polygon" do
    farm = Farm.create!(area: [[5,5],[6,5],[6,6],[5,6]])
    farm.area.should be_a RGeo::Geographic::SphericalPolygonImpl
  end


end
