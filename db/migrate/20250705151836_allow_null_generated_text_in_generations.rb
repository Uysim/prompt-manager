class AllowNullGeneratedTextInGenerations < ActiveRecord::Migration[7.2]
  def change
    # Allow generated_text to be null (only required when completed)
    change_column_null :generations, :generated_text, true
  end
end
