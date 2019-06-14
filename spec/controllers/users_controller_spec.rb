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

    describe 'GET #new' do
      it 'returns a success response' do
        get :new
        expect(response).to be_successful
      end
      it 'renders the new template' do
        get :new
        expect(response).to render_template(:new)
      end
    end

    describe 'POST #create' do
      let(:user) { create(:user) }

      before do
        allow_any_instance_of(User).to receive(:id).and_return(2)
      end

      context 'with valid attributes' do
        before do
          allow_any_instance_of(User).to receive(:save).and_return(user)
        end
        it 'saves the new add on in the database' do
          expect_any_instance_of(User).to receive(:save)
          post :create, params: { user: { email: 'pony@party.com' } }
        end

        it 'renders the create template' do
          post :create, params: { user: { email: 'pony@party.com' } }
          expect(response).to redirect_to users_path
        end

        it 'assigns the new user to user' do
          post :create, params: { user: { email: 'pony@party.com' } }
          expect(assigns(:user)).to be_a_kind_of(User)
        end
      end

      context 'with invalid attributes' do
        it "doesn't save the new user in the database" do
          expect do
            post :create, params: { user: { email: nil } }
          end.to_not change(User, :count)
        end

        it 'renders the create template' do
          post :create, params: { user: { email: nil } }
          expect(response).to render_template :new
        end
      end
    end

    describe 'PUT #update' do
      let(:user) { create(:user) }
      before do
        allow(User).to receive(:find).and_return(user)
        allow_any_instance_of(User).to receive(:id).and_return(2)
      end

      context 'with valid attributes' do
        before do
          allow_any_instance_of(User).to receive(:update).and_return(true)
        end
        it 'updates user in the database' do
          expect_any_instance_of(User).to receive(:update)
          put :update, params: { id: 2, user: { email: 'pony@party.com' } }
        end

        it 'renders the update template' do
          put :update, params: { id: 2, user: { email: 'pony@party.com' } }
          expect(response).to redirect_to users_path
        end

        it 'assigns the user to user' do
          put :update, params: { id: 2, user: { email: 'pony@party.com' } }
          expect(assigns(:user)).to be_a_kind_of(User)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(User).to receive(:update).and_return(false)
        end

        it "doesn't save the new user in the database" do
          expect do
            put :update, params: { id: 2, user: { email: nil } }
          end.to_not change(User, :count)
        end

        it 'renders the update template' do
          put :update, params: { id: 2, user: { email: nil } }
          expect(response).to render_template :edit
        end
      end
    end

    describe 'PUT #promote' do
      let(:user) { build_stubbed(:user) }
      before do
        allow(User).to receive(:find).and_return(user)
        allow(user).to receive(:update).and_return(true)
      end

      it 'locates UserAdmin is created' do
        expect(user).to receive(:update)
        put :promote, params: { user_id: 2 }
      end

      it 'redirects to organization users' do
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

      it 'locates UserAdmin is created' do
        expect(user).to receive(:update)
        put :demote, params: { user_id: 2 }
      end

      it 'redirects to organization users' do
        put :demote, params: { user_id: 2 }
        expect(response).to redirect_to users_path
      end
    end

    describe 'DELETE #destroy' do
      let(:user) { build_stubbed(:user) }
      before do
        allow(User).to receive(:find).and_return(user)
        allow(user).to receive(:destroy).and_return(true)
      end

      it 'deletes the user' do
        expect(user).to receive(:destroy)
        delete :destroy, params: { id: 1 }
      end

      it 'redirects to the users list' do
        delete :destroy, params: { id: 1 }
        expect(response).to redirect_to(users_path)
      end
    end
  end

  context 'anonymous user' do
    describe 'GET #new' do
      it 'returns a access denied' do
        expect { get :new }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe 'GET #index' do
      it 'returns an access denied' do
        expect { get :index }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  context 'signed in user' do
    let(:current_user) { build_stubbed(:user) }
    before do
      sign_in current_user
      allow(request.env['warden']).to receive(:authenticate!).and_return(current_user)
      allow(controller).to receive(:current_user).and_return(current_user)
    end
    describe 'GET #new' do
      it 'returns a access denied' do
        expect { get :new }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe 'GET #index' do
      it 'returns no errors' do
        expect { get :index }.not_to raise_error
      end
    end

    describe 'GET #edit' do
      let(:user) { build_stubbed(:user) }

      it 'returns an access denied message' do
        allow(User).to receive(:find).and_return(user)
        expect { get :edit, params: { id: 1 } }.to raise_error(CanCan::AccessDenied)
      end

      it 'does not return an access denied message' do
        allow(User).to receive(:find).and_return(current_user)
        expect { get :edit, params: { id: 1 } }.not_to raise_error
      end
    end
  end
end
