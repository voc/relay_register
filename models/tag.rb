class Tag < ActiveRecord::Base
  has_and_belongs_to_many :relays

  validates_uniqueness_of :name
end
