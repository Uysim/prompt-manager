class AddMetadataToGenerations < ActiveRecord::Migration[7.2]
  def change
    add_column :generations, :metadata, :jsonb, default: {}
    add_index :generations, :metadata, using: :gin
  end
end
