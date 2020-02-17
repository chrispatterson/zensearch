# frozen_string_literal: true

class DomainRegistration < ActiveRecord::Base
  belongs_to :domain_name
  belongs_to :organization
end
