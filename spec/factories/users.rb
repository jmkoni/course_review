# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'MyString' }
    years_experience { '' }
    is_admin { false }
  end
end
