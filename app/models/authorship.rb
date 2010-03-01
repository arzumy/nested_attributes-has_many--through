class Authorship < ActiveRecord::Base
  belongs_to :app
  belongs_to :developer
end
