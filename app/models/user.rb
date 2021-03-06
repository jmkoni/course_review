# frozen_string_literal: true

require 'securerandom'

class User < ApplicationRecord
  before_create :generate_uuid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validate :password_complexity

  has_many :reviews, dependent: :destroy

  filterrific(
    default_filter_params: { sorted_by: 'email_desc' },
    available_filters: %i[
      sorted_by
      search_query
    ]
  )

  scope :admins, -> {
    where(is_admin: true)
  }

  scope :search_query, ->(query) {
    return nil if query.blank?

    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map do |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    end
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 1
    where(
      terms.map do
        or_clauses = [
          'LOWER(users.email) LIKE ?'
        ].join(' OR ')
        "(#{or_clauses})"
      end.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, ->(sort_option) {
    # extract the sort direction from the param value.
    direction = /desc$/.match?(sort_option) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^email_/
      order(Arel.sql("LOWER(users.email) #{direction}"))
    when /^admin_/
      order(Arel.sql("users.is_admin #{direction}"))
    when /^deactivated_/
      order(Arel.sql("users.deactivated #{direction}"))
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def admin?
    is_admin
  end

  def self.options_for_sorted_by
    [
      ['Email (a-z)', 'email_asc'],
      ['Email (z-a)', 'email_desc'],
      ['Admin? (false first)', 'admin_asc'],
      ['Admin? (true first)', 'admin_desc']
    ]
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    return if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])/

    errors.add :password, 'Complexity requirement not met. Please use: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  deactivated            :boolean          default(FALSE)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  is_admin               :boolean          default(FALSE)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  uuid                   :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
