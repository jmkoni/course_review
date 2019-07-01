# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    name { Faker::Educator.course_name }
    sequence(:number) { |i| rand(100).to_s + "#{i}" }
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
