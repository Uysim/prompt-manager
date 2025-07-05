class AddStatusToGenerations < ActiveRecord::Migration[7.2]
  def change
    add_column :generations, :status, :string, default: 'pending', null: false
    add_index :generations, :status

    reversible do |dir|
      dir.up do
        Generation.update_all(status: 'completed')
      end
    end
  end
end
