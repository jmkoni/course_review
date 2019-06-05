# frozen_string_literal: true

require 'digest'
require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  context 'associations' do
    # it { should have_many :reviews }
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
  end

  context 'methods' do
    describe 'admin?' do
      it 'returns true if user is admin' do
        user = create(:admin)
        expect(user.admin?).to be true
      end
    end

    describe 'sha_email' do
      it 'returns an encrypted email address' do
        user = create(:user, email: 'test@ponyparty.com')
        sha = Digest::SHA1.new
        encrypted_email = sha.hexdigest 'test@ponyparty.com'
        expect(user.sha_email).to eq encrypted_email
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
