class CreateCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :courses do |t|
      t.string :name
      t.string :number
      t.string :department
      t.belongs_to :school, index: true

      t.timestamps
    end
  end
end
