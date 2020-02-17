# frozen_string_literal: true

class CreateTagsAndTaggings < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps null: false
    end

    create_table :taggings do |t|
      t.references :tag, foreign_key: true
      t.integer :taggable_id
      t.string :taggable_type
      t.timestamps null: false
    end
  end
end
