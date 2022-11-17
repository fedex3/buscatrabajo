class CreateJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :jobs do |t|
      t.string :name, null: false, :limit => 200
      t.string :name_id, :limit => 200, index: true
      t.boolean :remote, default: false
      t.string :detail, :limit => 20000
      t.integer :seniority
      t.datetime :deleted_at
      t.attachment :photo
      t.string :city, :limit => 100
      t.integer :views, :default => 0
      t.boolean :active, :default => false
      t.datetime :from_date, :default => DateTime.now.strftime("%Y-%m-%d"), index: true
      t.datetime :end_date, :default => DateTime.now.strftime("%Y-%m-%d"), index: true
      t.references :company, index: true, foreign_key: true
    end
  end
end
