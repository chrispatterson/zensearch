# frozen_string_literal: true

class CreateOrganizationsTicketsAndUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations do |t|
      t.string :url
      t.string :external_id, limit: 36, null: false
      t.integer :type, limit: 2, null: false, default: 1
      t.string :name
      t.string :details
      t.boolean :shared_tickets, null: false, default: false
      t.timestamps null: false

      t.index :id, unique: true
    end

    create_table :tickets, id: false do |t|
      t.string :id, limit: 36, null: false
      t.string :url
      t.string :external_id, limit: 36, null: false
      t.integer :type, limit: 2, null: false, default: 1
      t.string :subject
      t.text :description
      t.integer :priority, limit: 2, null: false, default: 3
      t.integer :status, limit: 2, null: false, default: 1
      t.references :submitter, foreign_key: { to_table: :users }, null: false
      t.references :assignee, foreign_key: { to_table: :users }
      t.references :organization, foreign_key: true
      t.boolean :has_incidents, null: false, default: false
      t.datetime :due_at
      t.integer :via, limit: 2, null: false, default: 1
      t.timestamps null: false

      t.index :id, unique: true
    end

    create_table :users do |t|
      t.string :url
      t.string :external_id, limit: 36, null: false
      t.string :name
      t.string :alias
      t.boolean :active, null: false, default: true
      t.boolean :verified, null: false, default: false
      t.boolean :shared, null: false, default: true
      t.string :locale, limit: 5
      t.string :timezone
      t.datetime :last_login_at
      t.string :email
      t.string :phone
      t.text :signature
      t.references :organization, foreign_key: true
      t.boolean :suspended, null: false, default: false
      t.integer :role, limit: 2, null: false, default: 1
      t.timestamps null: false
    end
  end
end
