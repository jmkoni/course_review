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
