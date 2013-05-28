require "spec_helper"

describe Mongoid::Fields do

  context "spatial" do
    before do
      Bar.create_indexes
    end

    it "should created indexes" do
      Bar.index_options.keys.should include({:location => '2d'})
    end

    it "should set spatial fields" do
      Bar.spatial_fields.should eql([:location])
    end

    it "should set some class methods" do
      far  = Bar.create!(name: "Far", location: [7,7])
      near = Bar.create!(name: "Near", location: [2,2])
      Bar.nearby([1,1]).should eq([near, far])
    end

    # it "should set some class methods" do
    #   far  = Bar.create!(name: "Far", location: [7,7])
    #   near = Bar.create!(name: "Near", location: [2,2])
    #   Bar.near_location([1,1]).should eq([near, far])
    # end

  end

  context "geom" do
  end

end
