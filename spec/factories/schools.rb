# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    name { Faker::University.name }
    short_name { Faker::Alphanumeric.alpha 4 }
  end
end

# == Schema Information
#
# Table name: schools
#
#  id         :bigint           not null, primary key
#  name       :string
#  short_name :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
