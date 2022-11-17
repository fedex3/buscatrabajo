class AddCountryToJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :country, :string
  end
end
