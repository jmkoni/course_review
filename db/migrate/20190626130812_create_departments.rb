class CreateDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|
      t.string :name
      t.string :short_name
      t.belongs_to :school, index: true
      t.timestamps
    end

    add_column :courses, :department_id, :integer, index: true
    remove_column :courses, :school_id, :integer
    remove_column :courses, :department, :string
  end
end
