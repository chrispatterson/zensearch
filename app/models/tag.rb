# frozen_string_literal: true

class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
end
