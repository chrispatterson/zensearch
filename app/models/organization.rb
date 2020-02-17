# frozen_string_literal: true

class Organization < ApplicationRecord
  include SearchableConcern
  boolean_attributes [:shared_tickets]
  fulltext_attributes %i[url external_id name details]
  join_attributes %i[domain_names tags]

  include UuidConcern
  uuid_attributes [:external_id]

  has_many :tickets
  has_many :users

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  has_many :domain_registrations, dependent: :destroy
  has_many :domain_names, through: :domain_registrations

  # Disable single-table inheritance
  self.inheritance_column = :ignore_the_type_column
end
