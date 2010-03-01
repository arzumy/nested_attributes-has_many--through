class Developer < ActiveRecord::Base
  has_many :authorships
  has_many :apps, :through => :authorships
end
