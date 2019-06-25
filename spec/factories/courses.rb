# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    name { Faker::Educator.course_name }
    number { rand(1000).to_s }
    department { Faker::Educator.subject }
    school
  end
end

# == Schema Information
#
# Table name: courses
#
#  id         :bigint           not null, primary key
#  department :string
#  name       :string
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint
#
# Indexes
#
#  index_courses_on_school_id  (school_id)
#
