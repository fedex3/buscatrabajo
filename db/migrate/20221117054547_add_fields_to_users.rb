class AddFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :name, :string, :limit => 100
    add_column :users, :country, :string, :limit => 50
    add_column :users, :deleted_at, :datetime
    add_column :users, :description, :string
    add_column :users, :role, :integer

    add_index :users, :deleted_at
  end
end
