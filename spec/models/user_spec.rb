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
        pending
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
  end
end