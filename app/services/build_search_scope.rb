# frozen_string_literal: true

class BuildSearchScope
  attr_reader :entity, :search_data, :search_fields
  attr_reader :scope

  def initialize(entity, search_data)
    @entity = entity
    @search_data = search_data.symbolize_keys

    @search_fields = build_search_fields(@search_data.keys, entity)
  end

  def self.call(entity, search_data)
    s = new(entity, search_data)
    s.go
    s
  end

  def go
    @scope = search_fields.blank? ? entity.none : entity.all.merge(scopes_to_search)
  end

  private

    def build_search_fields(keys, entity)
      return if keys.blank?

      {
        boolean: keys & entity.boolean_search_fields,
        date: keys & entity.date_search_fields,
        enum: keys & entity.enum_search_fields,
        join: keys & entity.join_search_fields,
        other: keys & entity.other_search_fields,
        text: (entity.fulltext_search_fields if keys.include? :text)
      }
    end

    def scopes_to_search
      scopes = [
        boolean_scope,
        date_scope,
        enum_scope,
        join_scope,
        other_scope,
        text_scope
      ]

      scopes.compact.reduce(:or)
    end

    def boolean_scope
      return unless search_fields[:boolean]

      conditions = search_fields[:boolean].map do |field|
        entity.where(field => search_data[field])
      end
      conditions.reduce(:or)
    end

    def date_scope
      return unless search_fields[:date]

      conditions = search_fields[:date].map do |field|
        entity.where(field => date_range(field))
      end
      conditions.reduce(:or)
    end

    def date_range(field)
      search_data[field].beginning_of_day..search_data[field].end_of_day
    end

    def enum_scope
      return unless search_fields[:enum]

      conditions = search_fields[:enum].map do |field|
        entity.where(field => enum_value(field))
      end
      conditions.reduce(:or)
    end

    def enum_value(field)
      entity.public_send(field.to_s.pluralize)[search_data[field]]
    end

    def join_scope
      return unless search_fields[:join]

      conditions = search_fields[:join].map do |field|
        entity.where(
          id: entity.joins(field)
            .where(field => { name: search_data[field] })
            .pluck(:id)
        )
      end
      conditions.reduce(:or)
    end

    def other_scope
      conditions = search_fields[:other].map do |field|
        entity.where(field => search_data[field])
      end
      conditions.reduce(:or)
    end

    def text_scope
      return unless search_fields[:text]

      search_data[:text].present? ? with_text_scope : blank_text_scope
    end

    def blank_text_scope
      conditions = entity.fulltext_search_fields.map do |field|
        entity.where(field => nil).or(entity.where(field => ''))
      end
      conditions.reduce(:or)
    end

    def with_text_scope
      conditions = entity.fulltext_search_fields.map do |field|
        entity.where(
          entity.arel_table[field].matches("%#{search_data[:text]}%")
        )
      end
      conditions.reduce(:or)
    end
end
