# frozen_string_literal: true

class CreateDomainNamesAndDomainRegistrations < ActiveRecord::Migration[6.0]
  def change
    create_table :domain_names do |t|
      t.string :name, null: false
      t.timestamps null: false
    end

    create_table :domain_registrations do |t|
      t.references :domain_name, foreign_key: true
      t.references :organization, foreign_key: true
      t.timestamps null: false
    end
  end
end
