course.department.schoolrequire 'securerandom'
class AddUserUuid < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :uuid, :string

    User.reset_column_information
    User.all.each do |user|
      user.update_attributes!(uuid: SecureRandom.uuid)
    end

    change_column :users, :uuid, :string, null: false
  end
end
