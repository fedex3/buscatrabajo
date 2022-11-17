class AddApplicationCounter < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :application_counter, :integer, :default => 0
  end
end
