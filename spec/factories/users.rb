# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |i| Faker::Internet.email("test#{i}") }
    years_experience { rand(10) }
    is_admin { false }
    password { Faker::Internet.password(10, 20) }

    factory :admin do
      is_admin { true }
    end
  end
end
