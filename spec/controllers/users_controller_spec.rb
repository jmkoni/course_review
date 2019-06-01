# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:current_user) { build_stubbed(:admin) }

  describe 'GET #index' do
    before do
      # @ability.can :read, User
      @users = [build_stubbed(:user), build_stubbed(:user)]
      allow_any_instance_of(User).to receive(:admin?).and_return(true)
      allow(User).to receive(:all).and_return(@users)
      allow(User).to receive(:where).and_return(@users)
    end

    it 'calls all' do
      expect(User).to receive(:all)
      get :index
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_success
    end

    it 'assigns users to @users' do
      get :index
      expect(assigns(:users)).to eq(@users)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    # before { @ability.can :create, User }
    it 'returns a success response' do
      get :new
      expect(response).to be_success
    end
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }

    before do
      # @ability.can :create, User
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
      # @ability.can :update, User
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
        expect(response).to redirect_to user_path(id: 2)
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
      # @ability.can :promote, User
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
      # @ability.can :demote, User
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
      # @ability.can :destroy, User
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
