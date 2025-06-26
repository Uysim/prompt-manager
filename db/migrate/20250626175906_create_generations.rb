class CreateGenerations < ActiveRecord::Migration[7.2]
  def change
    create_table :generations, id: :uuid do |t|
      t.references :prompt, null: false, foreign_key: true, type: :uuid
      t.jsonb :input_data, null: false, default: {}
      t.text :generated_text, null: false
      t.string :llm_provider, null: false
      t.string :llm_model, null: false

      t.timestamps
    end

    add_index :generations, :created_at
    add_index :generations, [ :prompt_id, :created_at ]
  end
end
