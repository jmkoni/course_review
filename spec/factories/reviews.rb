# frozen_string_literal: true

FactoryBot.define do
  factory :review do
    course
    user
    notes { Faker::Lorem.paragraph }
    work_required { rand(10) }
    difficulty { rand(10) }
    rating { rand(10) }
    experience_with_topic { false }
    year { rand(2000..2019) }
    term { rand(4) }
    grade { rand(100) }
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
