# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = :created_at

  alias_attribute :_id, :id

  def tags=(_placeholder)
  end
end
