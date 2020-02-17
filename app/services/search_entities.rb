# frozen_string_literal: true

class SearchEntities
  attr_reader :entity, :search_data
  attr_reader :results

  SEARCHABLE_MODELS = [Organization, Ticket, User].freeze

  def initialize(entity, search_data)
    raise ArgumentError, 'unsupported model' unless SEARCHABLE_MODELS.include? entity
    raise ArgumentError, 'search_data must be a hash' unless search_data.is_a? Hash

    @entity = entity
    @search_data = search_data.symbolize_keys

    raise ArgumentError, 'unsupported search fields' if (
      @search_data.keys -
      [:text] -
      entity.searchable_fields
    ).present?
  end

  def self.call(entity, search_data)
    s = new(entity, search_data)
    s.go
    s
  end

  def go
    @results = entity.merge([
      boolean_scope,
      date_scope,
      enum_scope,
      other_scope,
      text_scope
    ].reduce(:or))
  end

  def boolean_scope
    fields = search_data.keys & entity.boolean_search_fields
    return entity.none unless fields.present?

    conditions = fields.map do |field|
      entity.where(field => search_data[field])
    end

    conditions.reduce(:or)
  end

  def date_scope
    fields = search_data.keys & entity.date_search_fields
    return entity.none unless fields.present?

    conditions = fields.map do |field|
      entity.where(field => date_range(field))
    end

    conditions.reduce(:or)
  end

  def date_range(field)
    search_data[field].beginning_of_day..search_data[field].end_of_day
  end

  def enum_scope
    fields = search_data.keys & entity.enum_search_fields
    return entity.none unless fields.present?

    conditions = fields.map do |field|
      entity.where(field => enum_value(field))
    end

    conditions.reduce(:or)
  end

  def enum_value(field)
    entity.public_send(field.to_s.pluralize)[search_data[field]]
  end

  def other_scope
    fields = search_data.keys & entity.other_search_fields
    return entity.none unless fields.present?

    conditions = fields.map do |field|
      entity.where(field => search_data[field])
    end

    conditions.reduce(:or)
  end

  def text_scope
    return entity.none unless search_data.key? :text

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
