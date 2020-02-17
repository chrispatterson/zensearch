# frozen_string_literal: true

class Organization < ApplicationRecord
  include SearchableConcern
  boolean_attributes [:shared_tickets]
  fulltext_attributes %i[url external_id name details]
  join_attributes %i[tags]

  include UuidConcern
  uuid_attributes [:external_id]

  has_many :tickets
  has_many :users

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  # Disable single-table inheritance
  self.inheritance_column = :ignore_the_type_column

  def domain_names=(_placeholder)
  end
end
