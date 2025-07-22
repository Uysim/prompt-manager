class AddGeneratedPromptToGeneration < ActiveRecord::Migration[7.2]
  def change
    add_column :generations, :generated_prompt, :text
  end
end
