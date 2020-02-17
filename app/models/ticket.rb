# frozen_string_literal: true

class Ticket < ApplicationRecord
  include SearchableConcern
  boolean_attributes [:has_incidents]
  date_attributes [:due_at]
  enum_attributes %i[priority status type via]
  fulltext_attributes %i[id url external_id subject description]
  other_attributes %i[submitter_id assignee_id organization_id]

  include UuidConcern
  uuid_attributes %i[id external_id]

  self.primary_key = :id

  belongs_to :organization, optional: true
  belongs_to :submitter, class_name: 'User'
  belongs_to :assignee, class_name: 'User', optional: true

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  enum priority: {
    urgent: 1,
    high: 2,
    normal: 3,
    low: 4
  }

  enum status: {
    open: 1,
    pending: 2,
    hold: 3,
    closed: 4,
    solved: 5
  }, _prefix: true

  enum type: {
    incident: 1,
    problem: 2,
    question: 3,
    task: 4
  }

  enum via: {
    web: 1,
    chat: 2,
    voice: 3
  }

  # Disable single-table inheritance
  self.inheritance_column = :ignore_the_type_column
end
