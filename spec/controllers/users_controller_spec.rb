# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  context 'admin' do
    let(:current_user) { create(:admin) }
    before do
      sign_in current_user
      allow(request.env['warden']).to receive(:authenticate!).and_return(current_user)
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    describe 'GET #index' do
      before do
        @users = [create(:user), create(:user), current_user]
      end

      it 'returns a success response' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns users to @users' do
        get :index
        expect(assigns(:users).size).to eq(3)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    describe 'PUT #promote' do
      let(:user) { build_stubbed(:user) }
      before do
        allow(User).to receive(:find).and_return(user)
        allow(user).to receive(:update).and_return(true)
      end

      it 'updates user' do
        expect(user).to receive(:update)
        put :promote, params: { user_id: 2 }
      end

      it 'redirects to users' do
        put :promote, params: { user_id: 2 }
        expect(response).to redirect_to users_path
      end
    end

    describe 'PUT #demote' do
      let(:user) { build_stubbed(:user) }
      before do
        allow(User).to receive(:find).and_return(user)
        allow(user).to receive(:update).and_return(true)
      end

      it 'updates user' do
        expect(user).to receive(:update)
        put :demote, params: { user_id: 2 }
      end

      it 'redirects to users' do
        put :demote, params: { user_id: 2 }
        expect(response).to redirect_to users_path
      end
    end

    describe 'PUT #deactivate' do
      let(:user) { build_stubbed(:user) }
      before do
        allow(User).to receive(:find).and_return(user)
        allow(user).to receive(:update).and_return(true)
      end

      it 'updates user' do
        expect(user).to receive(:update)
        put :deactivate, params: { user_id: 2 }
      end

      it 'redirects to users' do
        put :deactivate, params: { user_id: 2 }
        expect(response).to redirect_to users_path
      end
    end

    describe 'PUT #reactivate' do
      let(:user) { build_stubbed(:user) }
      before do
        allow(User).to receive(:find).and_return(user)
        allow(user).to receive(:update).and_return(true)
      end

      it 'updates user' do
        expect(user).to receive(:update)
        put :reactivate, params: { user_id: 2 }
      end

      it 'redirects to users' do
        put :reactivate, params: { user_id: 2 }
        expect(response).to redirect_to users_path
      end
    end
  end

  context 'anonymous user' do
    describe 'GET #index' do
      it 'returns an access denied' do
        expect { get :index }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  context 'signed in user' do
    let(:current_user) { build_stubbed(:user) }
    let(:user) { build_stubbed(:user) }

    before do
      allow(User).to receive(:find).and_return(user)
      sign_in current_user
      allow(request.env['warden']).to receive(:authenticate!).and_return(current_user)
      allow(controller).to receive(:current_user).and_return(current_user)
    end
    describe 'PUT #deactivate' do
      it 'returns a access denied' do
        expect { put :deactivate, params: { user_id: 1 } }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe 'GET #index' do
      it 'returns no errors' do
        expect { get :index }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe 'GET #deactivate' do
      let(:user) { build_stubbed(:user) }

      it 'returns an access denied message' do
        allow(User).to receive(:find).and_return(user)
        expect { put :deactivate, params: { user_id: 1 } }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
