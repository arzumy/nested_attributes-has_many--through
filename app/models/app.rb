class App < ActiveRecord::Base
  has_many    :authorships
  has_many    :developers,  :through => :authorships
  accepts_nested_attributes_for :developers,  :reject_if => proc { |obj| obj[:name].blank? }
end
