FactoryBot.define do
  factory :department do
    sequence(:name) { |i| Faker::Educator.subject + " test#{i}" }
    short_name { Faker::Alphanumeric.alpha(4).upcase }
    school
  end
end

# == Schema Information
#
# Table name: departments
#
#  id         :bigint           not null, primary key
#  name       :string
#  short_name :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint
#
# Indexes
#
#  index_departments_on_school_id  (school_id)
#
