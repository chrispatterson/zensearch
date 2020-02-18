# frozen_string_literal: true

class SearchEntities
  attr_reader :entity, :search_data
  attr_reader :results

  SEARCHABLE_MODELS = [Organization, Ticket, User].freeze

  def initialize(entity, search_data)
    raise ArgumentError, 'unsupported model' unless SEARCHABLE_MODELS.include? entity
    raise ArgumentError, 'search_data must be a hash' unless search_data.is_a? Hash

    @entity = entity
    @search_data = search_data
  end

  def self.call(entity, search_data)
    s = new(entity, search_data)
    s.go
    s
  end

  def go
    @results = entity.all.merge(BuildSearchScope.call(entity, search_data).scope)
  end
end
