class CreateCompaniesIndustries < ActiveRecord::Migration[5.1]
  def change
    create_table :companies_industries do |t|
      t.references :industry, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
    end
  end
end
