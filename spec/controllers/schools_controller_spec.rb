# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolsController, type: :controller do
  let(:current_user) { build_stubbed(:admin) }
  let(:valid_attributes) { { name: 'Unicorn University', short_name: 'uniu'} }
  before do
    sign_in current_user
    allow(request.env['warden']).to receive(:authenticate!).and_return(current_user)
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe 'GET #index' do
    before do
      @schools = [build_stubbed(:school), build_stubbed(:school)]
      allow(School).to receive(:all).and_return(@schools)
    end

    it 'calls all' do
      expect(School).to receive(:all)
      get :index
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_success
    end

    it 'assigns schools to @schools' do
      get :index
      expect(assigns(:schools)).to eq(@schools)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
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
    let(:school) { create(:school) }

    before do
      allow_any_instance_of(School).to receive(:id).and_return(2)
    end

    context 'with valid attributes' do
      before do
        allow_any_instance_of(School).to receive(:save).and_return(school)
      end
      it 'saves the new add on in the database' do
        expect_any_instance_of(School).to receive(:save)
        post :create, params: { school: valid_attributes }
      end

      it 'renders the create template' do
        post :create, params: { school: valid_attributes }
        expect(response).to redirect_to schools_path
      end

      it 'assigns the new school to school' do
        post :create, params: { school: valid_attributes }
        expect(assigns(:school)).to be_a_kind_of(School)
      end
    end

    context 'with invalid attributes' do
      it "doesn't save the new school in the database" do
        expect do
          post :create, params: { school: { email: nil } }
        end.to_not change(School, :count)
      end

      it 'renders the create template' do
        post :create, params: { school: { email: nil } }
        expect(response).to render_template :new
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit
      expect(response).to be_success
    end
    it 'renders the edit template' do
      get :edit
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT #update' do
    let(:school) { create(:school) }
    before do
      allow(School).to receive(:find).and_return(school)
      allow_any_instance_of(School).to receive(:id).and_return(2)
    end

    context 'with valid attributes' do
      before do
        allow_any_instance_of(School).to receive(:update).and_return(true)
      end
      it 'updates school in the database' do
        expect_any_instance_of(School).to receive(:update)
        put :update, params: { id: 2, school: valid_attributes }
      end

      it 'renders the update template' do
        put :update, params: { id: 2, school: valid_attributes }
        expect(response).to redirect_to school_path(id: 2)
      end

      it 'assigns the school to school' do
        put :update, params: { id: 2, school: valid_attributes }
        expect(assigns(:school)).to be_a_kind_of(School)
      end
    end

    context 'with invalid attributes' do
      before do
        allow_any_instance_of(School).to receive(:update).and_return(false)
      end

      it "doesn't save the new school in the database" do
        expect do
          put :update, params: { id: 2, school: { email: nil } }
        end.to_not change(School, :count)
      end

      it 'renders the update template' do
        put :update, params: { id: 2, school: { email: nil } }
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:school) { build_stubbed(:school) }
    before do
      allow(School).to receive(:find).and_return(school)
      allow(school).to receive(:destroy).and_return(true)
    end

    it 'deletes the school' do
      expect(school).to receive(:destroy)
      delete :destroy, params: { id: 1 }
    end

    it 'redirects to the schools list' do
      delete :destroy, params: { id: 1 }
      expect(response).to redirect_to(schools_path)
    end
  end
end
