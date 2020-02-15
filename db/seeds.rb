# frozen_string_literal: true

IMPORT_ENTITIES = [Organization, User, Ticket].freeze

IMPORT_ENTITIES.each do |entity|

  if entity.count == 0
    path = File.join(File.dirname(__FILE__), "./seeds/#{entity.table_name}.json")

    records = JSON.parse(File.read(path))

    records.each do |record|
      entity.create!(record)
      print '.'
    end
    
    puts "\n🌱 #{entity} list imported\n"
  end

end
