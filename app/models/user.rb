# frozen_string_literal: true

class User < ApplicationRecord
  include SearchableConcern
  boolean_attributes %i[active verified shared suspended]
  date_attributes [:last_login_at]
  enum_attributes [:role]
  fulltext_attributes %i[url external_id name user_alias email phone signature]
  other_attributes %i[locale timezone organization_id]

  include UuidConcern
  uuid_attributes [:external_id]

  belongs_to :organization, optional: true

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  enum role: {
    'end-user': 1,
    agent: 2,
    admin: 3
  }

  alias_attribute :alias, :user_alias
end
