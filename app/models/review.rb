class Review < ApplicationRecord
  validates :rating, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :course_id }
  validates_numericality_of :grade, in: 0..100
  validates_numericality_of :rating, in: 0..10
  validates_numericality_of :difficulty, in: 0..10
  validates_numericality_of :year, in: 1990..Time.now.year
  validates_numericality_of :term, in: 1..10
  validates_numericality_of :work_required, in: 0..100

  belongs_to :course
  belongs_to :user
  has_one :school, through: :course

  def letter_grade
    case grade
      when 90..100
        "A"
      when 80..90
        "B"
      when 70..80
        "C"
      when 60..70
        "D"
      when 0..60
        "F"
      else
        "Error"
      end
  end

  def display_grade
    "#{grade}% (#{letter_grade})"
  end
end

# == Schema Information
#
# Table name: reviews
#
#  id                    :bigint           not null, primary key
#  difficulty            :integer
#  experience_with_topic :boolean
#  grade                 :integer
#  notes                 :string
#  rating                :integer
#  term                  :integer
#  work_required         :integer
#  year                  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  course_id             :bigint
#  user_id               :bigint
#
# Indexes
#
#  index_reviews_on_course_id  (course_id)
#  index_reviews_on_user_id    (user_id)
#
