# frozen_string_literal: true

module SearchableConcern
  extend ActiveSupport::Concern

  SEARCHABLE_FIELD_GROUPS = %i[
    boolean_search_fields
    date_search_fields
    enum_search_fields
    fulltext_search_fields
    join_search_fields
    other_search_fields
  ].freeze

  # rubocop:disable Metrics/BlockLength
  included do
    def self.boolean_attributes(attributes = [])
      singleton_class.instance_eval do
        define_method(:boolean_search_fields) do
          attributes
        end
      end
    end

    def self.date_attributes(attributes = [])
      singleton_class.instance_eval do
        define_method(:date_search_fields) do
          attributes
        end
      end
    end

    def self.enum_attributes(attributes = [])
      singleton_class.instance_eval do
        define_method(:enum_search_fields) do
          attributes
        end
      end
    end

    def self.fulltext_attributes(attributes = [])
      singleton_class.instance_eval do
        define_method(:fulltext_search_fields) do
          attributes
        end
      end
    end

    def self.join_attributes(attributes = [])
      singleton_class.instance_eval do
        define_method(:join_search_fields) do
          attributes
        end
      end
    end

    def self.other_attributes(attributes = [])
      singleton_class.instance_eval do
        define_method(:other_search_fields) do
          attributes
        end
      end
    end

    def self.other_attributes(attributes = [])
      singleton_class.instance_eval do
        define_method(:other_search_fields) do
          attributes
        end
      end
    end

    # Add default accessors
    SEARCHABLE_FIELD_GROUPS.each do |field_group|
      next if respond_to? field_group

      singleton_class.instance_eval do
        define_method(field_group) do
          []
        end
      end
    end
  end
  # rubocop:enable Metrics/BlockLength

  class_methods do
    define_method(:searchable_fields) do
      @searchable_fields ||=
        boolean_search_fields +
        date_search_fields +
        enum_search_fields +
        fulltext_search_fields +
        join_search_fields +
        other_search_fields
    end
  end
end
