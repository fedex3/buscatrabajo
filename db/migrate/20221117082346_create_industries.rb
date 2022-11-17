class CreateIndustries < ActiveRecord::Migration[5.1]
  def change
    create_table :industries do |t|
      t.string :name, :limit => 200
      t.string :name_id, :limit => 200
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
  end
end
