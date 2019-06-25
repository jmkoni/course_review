# typed: true
class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.belongs_to :course, index: true
      t.belongs_to :user, index: true
      t.string :notes
      t.integer :work_required
      t.integer :difficulty
      t.integer :rating
      t.boolean :experience_with_topic
      t.integer :year
      t.integer :term
      t.integer :grade

      t.timestamps
    end
  end
end
