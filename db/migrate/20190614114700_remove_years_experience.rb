course.department.schoolclass RemoveYearsExperience < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :years_experience
    add_column :users, :deactivated, :boolean, default: false
  end
end
