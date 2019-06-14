# frozen_string_literal: true

require 'digest'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: { case_sensitive: false }

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
    when /^years_experience_/
      order(Arel.sql("users.years_experience #{direction}"))
    when /^admin_/
      order(Arel.sql("users.is_admin #{direction}"))
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def admin?
    is_admin
  end

  def sha_email
    sha = Digest::SHA1.new
    sha.hexdigest email
  end

  def self.options_for_sorted_by
    [
      ['Email (a-z)', 'email_asc'],
      ['Email (z-a)', 'email_desc'],
      ['Years Experience (lowest first)', 'years_experience_asc'],
      ['Years Experience (highest first)', 'years_experience_desc'],
      ['Admin? (false first)', 'admin_asc'],
      ['Admin? (true first)', 'admin_desc']
    ]
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
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  is_admin               :boolean
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  years_experience       :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
