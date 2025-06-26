class CreatePrompts < ActiveRecord::Migration[7.2]
  def change
    create_table :prompts, id: :uuid do |t|
      t.string :title, null: false, index: { unique: true }
      t.text :content, null: false
      t.text :description
      t.jsonb :variables, default: {}

      t.timestamps
    end
  end
end
