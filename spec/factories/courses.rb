# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    name { Faker::Educator.course_name }
    number { rand(1000).to_s }
    department
  end
end

# == Schema Information
#
# Table name: courses
#
#  id            :bigint           not null, primary key
#  name          :string
#  number        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  department_id :integer
#
