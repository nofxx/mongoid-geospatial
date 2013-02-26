class Bar
  include Mongoid::Document
  include Mongoid::Geospatial

  field :name,     :type => String
  
  geo_field :location

  has_one :rating, :as => :ratable

  spatial_scope :location
end
