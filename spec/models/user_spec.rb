# frozen_string_literal: true

require 'digest'
require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    it 'validates complexity of password' do
      user1 = build(:user)
      user2 = build(:user, password: 'abc')
      aggregate_failures do
        expect(user1.valid?).to eq true
        expect(user2.valid?).to eq false
        expect(user2.errors.full_messages).to include 'Password Complexity requirement not met. Please use: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
        expect(user2.errors.full_messages).to include 'Password is too short (minimum is 10 characters)'
      end
    end
  end

  context 'associations' do
    it { should have_many :reviews }
  end

  context 'scopes' do
    describe 'admins' do
      it 'gets all users that are admins' do
        user1 = create(:user)
        user2 = create(:admin)
        user3 = create(:admin)
        aggregate_failures do
          expect(User.admins.length).to eq 2
          expect(User.admins).to include user2
          expect(User.admins).to include user3
          expect(User.admins).not_to include user1
        end
      end
    end

    describe 'search_query' do
      it 'gets all users with query' do
        user1 = create(:user, email: 'unicorns@gmail.com')
        user2 = create(:user, email: 'oh_no@test.com')
        user3 = create(:user, email: 'bye@test.com')
        aggregate_failures do
          expect(User.search_query('unicorns').length).to eq 1
          expect(User.search_query('unicorns')).to include user1
          expect(User.search_query('unicorns')).not_to include user2
          expect(User.search_query('unicorns')).not_to include user3
        end
      end
    end

    describe 'sorted_by' do
      it 'gets all users sorted' do
        user1 = create(:user, email: 'Alphabets@test.com', is_admin: true)
        user2 = create(:user, email: 'Zebra@test.com', is_admin: false)
        user3 = create(:user, email: 'Cows@test.com', is_admin: false, deactivated: true)
        aggregate_failures do
          expect(User.sorted_by('email_asc').first).to eq user1
          expect(User.sorted_by('email_desc').first).to eq user2
          expect(User.sorted_by('admin_desc').first).to eq user1
          expect(User.sorted_by('deactivated_desc').first).to eq user3
          expect { User.sorted_by('oh_no') }.to raise_error(ArgumentError, 'Invalid sort option: "oh_no"')
        end
      end
    end
  end

  context 'methods' do
    describe 'admin?' do
      it 'returns true if user is admin' do
        user = create(:admin)
        expect(user.admin?).to be true
      end
    end
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
