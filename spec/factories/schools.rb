# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::University.name }
    short_name { Faker::Alphanumeric.alpha 4 }
  end
end