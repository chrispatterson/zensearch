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
        text: keys & entity.fulltext_search_fields
      }
    end

    def scopes_to_search
      [
        boolean_scope, date_scope, enum_scope, join_scope, other_scope, text_scope
      ].compact.reduce(:or)
    end

    def boolean_scope
      return unless search_fields[:boolean]

      search_fields[:boolean].map do |field|
        entity.where(field => search_data[field])
      end.reduce(:or)
    end

    def date_scope
      return unless search_fields[:date]

      search_fields[:date].map do |field|
        entity.where(field => date_range(field))
      end.reduce(:or)
    end

    def date_range(field)
      search_data[field].beginning_of_day..search_data[field].end_of_day
    end

    def enum_scope
      return unless search_fields[:enum]

      search_fields[:enum].map do |field|
        entity.where(field => enum_value(field))
      end.reduce(:or)
    end

    def enum_value(field)
      entity.public_send(field.to_s.pluralize)[search_data[field]]
    end

    def join_scope
      return unless search_fields[:join]

      search_fields[:join].map do |field|
        entity.where(
          id: entity.joins(field)
            .where(field => { name: search_data[field] })
            .pluck(:id)
        )
      end.reduce(:or)
    end

    def other_scope
      search_fields[:other].map do |field|
        entity.where(field => search_data[field])
      end.reduce(:or)
    end

    def text_scope
      return unless search_fields[:text]

      text_fields = search_data.slice(*search_fields[:text])

      blank_text_fields = text_fields.select { |_key, value| value.blank? }
      present_text_fields = text_fields.select { |_key, value| value.present? }

      [
        blank_text_scope(blank_text_fields),
        with_text_scope(present_text_fields)
      ].compact.reduce(:or)
    end

    def blank_text_scope(fields)
      fields.map do |field, _value|
        entity.where(field => nil).or(entity.where(field => ''))
      end.reduce(:or)
    end

    def with_text_scope(fields)
      fields.map do |field, value|
        entity.where(
          entity.arel_table[field].matches("%#{value}%")
        )
      end.reduce(:or)
    end
end
