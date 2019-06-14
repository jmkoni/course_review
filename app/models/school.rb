# frozen_string_literal: true

class School < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :short_name, presence: true, uniqueness: { case_sensitive: false }
  has_many :courses, dependent: :destroy

  def self.options_for_select
    schools = School.arel_table
    order(schools[:name].lower).pluck(:name, :id)
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
