class AddCreationAndUpdateDateToJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :created_at, :datetime, index: true
    add_column :jobs, :updated_at, :datetime
  end
end
