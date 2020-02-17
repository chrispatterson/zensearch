# frozen_string_literal: true

class DomainName < ActiveRecord::Base
  has_many :domain_registrations, dependent: :destroy
  has_many :organizations, through: :domain_registrations
end
