# frozen_string_literal: true

class Organization < ApplicationRecord
  include UuidConcern
  uuid_attributes [:external_id]

  has_many :tickets
  has_many :users

  # Disable single-table inheritance
  self.inheritance_column = :ignore_the_type_column

  SEARCHABLE_BOOLEAN_FIELDS = [:shared_tickets].freeze
  SEARCHABLE_TEXT_FIELDS = %i[url external_id name details].freeze

  SEARCHABLE_FIELDS = (SEARCHABLE_BOOLEAN_FIELDS + SEARCHABLE_TEXT_FIELDS).freeze

  def domain_names=(_placeholder)
  end
end
