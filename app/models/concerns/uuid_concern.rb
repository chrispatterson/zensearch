# frozen_string_literal: true

module UuidConcern
  extend ActiveSupport::Concern

  included do
    def self.uuid_attributes(attributes = [])
      # Load securerandom only when uuid_attributes is used.
      require 'active_support/core_ext/securerandom'

      attributes.each do |attribute|
        before_create do
          public_send("#{attribute}=", self.class.generate_uuid) unless public_send("#{attribute}?")
        end
      end
    end

    def self.generate_uuid
      SecureRandom.uuid
    end
  end
end
