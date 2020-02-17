# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = :created_at

  alias_attribute :_id, :id

  def all_tags=(names)
    tag_set = []
    names.map do |name|
      tag_set << Tag.where(name: name.strip).first_or_create!
    end
    self.tags = tag_set
  end
end
