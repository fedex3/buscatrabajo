class AddCvToUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      t.attachment :cv
    end
  end
end
