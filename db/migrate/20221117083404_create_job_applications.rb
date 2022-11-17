class CreateJobApplications < ActiveRecord::Migration[5.1]
  def change
    create_table :job_applications do |t|
      t.references :job, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :comment, :limit => 500

      t.timestamps null: false
    end
  end
end
