# frozen_string_literal: true

class SearchEntities
  attr_reader :entity, :search_data
  attr_reader :results

  SEARCHABLE_MODELS = [Organization, Ticket, User].freeze

  def initialize(entity, search_params)
    raise ArgumentError, 'unsupported model' unless SEARCHABLE_MODELS.include? entity
    raise ArgumentError, 'search_data must be a hash' unless search_params.is_a? Hash

    @entity = entity
    @search_data = process_search_data(search_params)
  end

  def self.call(entity, search_params)
    s = new(entity, search_params)
    s.go
    s
  end

  def go
    @results = entity.all.merge(BuildSearchScope.call(entity, search_data).scope)
  end

  private

    def process_search_data(search_params)
      data = search_params.dup
      text_search_value = data.delete :text

      if text_search_value
        entity.fulltext_search_fields.each do |field|
          data[field] = text_search_value
        end
      end

      data[:id] = data.delete(:_id) if data.key?(:_id)

      data
    end
end
