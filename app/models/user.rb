# frozen_string_literal: true

class User < ApplicationRecord
  include UuidConcern
  uuid_attributes [:external_id]

  belongs_to :organization, optional: true

  enum role: {
    'end-user': 1,
    agent: 2,
    admin: 3
  }
end
