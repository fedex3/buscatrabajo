class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name, :limit => 200
      t.string :name_id, :limit => 200
      t.attachment :logo
      t.attachment :main_photo
      t.attachment :cover_photo
      t.string :city, :limit => 100
      t.string :country, :limit => 100
      t.string :detail, :limit => 20000
     
      t.integer :views, :default => 0
      t.boolean :active, :default => false
      t.datetime :from_date, :default => DateTime.now.strftime("%Y-%m-%d")

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
