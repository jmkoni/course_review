class AddProfToReview < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :teacher, :string
  end
end
