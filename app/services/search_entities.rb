# frozen_string_literal: true

class SearchEntities
  attr_reader :entity, :search_data
  attr_reader :results

  SEARCHABLE_MODELS = [Organization, Ticket, User].freeze

  def initialize(entity, search_params)
    raise ArgumentError, 'unsupported model' unless SEARCHABLE_MODELS.include? entity
    raise ArgumentError, 'search_data must be a hash' unless search_params.is_a? Hash

    @entity = entity
    @search_data = search_params.dup.with_indifferent_access
  end

  def self.call(entity, search_params)
    s = new(entity, search_params)
    s.go
    s
  end

  def go
    process_booleans
    process_dates
    process_id
    process_text

    @results = entity.all.merge(BuildSearchScope.call(entity, search_data).scope)
  end

  private

    def process_booleans
      entity.boolean_search_fields.each do |field|
        next unless search_data[field]

        search_data[field] = ActiveModel::Type::Boolean.new.cast(search_data[field])
      end
    end

    def process_dates
      entity.date_search_fields.each do |field|
        next unless search_data[field]

        search_data[field] = Date.parse(search_data[field])
      end
    end

    def process_id
      search_data[:id] = search_data.delete(:_id) if search_data.key?(:_id)
    end

    def process_text
      text_search_value = search_data.delete :text

      return unless text_search_value

      entity.fulltext_search_fields.each do |field|
        search_data[field] = text_search_value
      end
    end
end
