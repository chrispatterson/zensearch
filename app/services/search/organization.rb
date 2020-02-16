# frozen_string_literal: true

module Search
  class Organization
    attr_reader :search_data
    attr_reader :results

    def initialize(search_data)
      raise ArgumentError, 'search_data must be a hash' unless search_data.is_a? Hash

      @search_data = search_data.symbolize_keys

      raise ArgumentError, 'unsupported search fields' if (
        @search_data.keys -
        [:text] -
        ::Organization::SEARCHABLE_FIELDS
      ).present?
    end

    def self.call(search_data)
      s = new(search_data)
      s.go
      s
    end

    def go
      @results = ::Organization.merge([text_scope, boolean_scope].reduce(:or))
    end

    def text_scope
      return ::Organization.none unless search_data.key? :text

      search_data[:text].present? ? present_text_scope : blank_text_scope
    end

    def present_text_scope
      conditions = ::Organization::SEARCHABLE_TEXT_FIELDS.map do |field|
        ::Organization.where(
          ::Organization.arel_table[field].matches("%#{search_data[:text]}%")
        )
      end

      conditions.reduce(:or)
    end

    def blank_text_scope
      conditions = ::Organization::SEARCHABLE_TEXT_FIELDS.map do |field|
        ::Organization.where(field => nil).or(::Organization.where(field => ''))
      end

      conditions.reduce(:or)
    end

    def boolean_scope
      return ::Organization.none unless search_data[:shared_tickets].present?

      ::Organization.where(shared_tickets: search_data[:shared_tickets])
    end
  end
end
