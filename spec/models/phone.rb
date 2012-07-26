class Phone
  include Mongoid::Document
  field :number
  if Mongoid::VERSION <  '3'
    key :number
  end
  embeds_one :country_code
  embedded_in :person
end
