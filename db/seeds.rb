# frozen_string_literal: true

IMPORT_ENTITIES = [Organization, User, Ticket].freeze

def names_to_models(entity, array)
  models = []
  array.map do |name|
    models << entity.where(name: name.strip).first_or_create!
  end
   models
end

IMPORT_ENTITIES.each do |entity|

  if entity.count == 0
    path = File.join(File.dirname(__FILE__), "./seeds/#{entity.table_name}.json")

    records = JSON.parse(File.read(path)).with_indifferent_access

    records.each do |record|
      tags = record[:tags]
      domain_names = record[:domain_names]

      record[:tags] = names_to_models(Tag, tags) if tags.present?
      record[:domain_names] = names_to_models(DomainName, domain_names) if domain_names.present?

      model = entity.new(record)
      model.save!(validate: false)
      print '.'
    end

    puts "\n🌱 #{entity} list imported\n"
  end

end
