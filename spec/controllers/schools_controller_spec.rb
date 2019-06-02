# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  let(:current_user) { build_stubbed(:admin) }
  let(:course) { create(:course) }
  let(:valid_attributes) { { name: 'Unicorn University', short_name: 'uniu'} }
  before do
    sign_in current_user
    allow(request.env['warden']).to receive(:authenticate!).and_return(current_user)
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe 'GET #index' do
    before do
      @courses = [build_stubbed(:course), build_stubbed(:course)]
      allow(Course).to receive(:all).and_return(@courses)
      allow(Course).to receive(:where).and_return(@courses)
    end

    it 'calls all' do
      expect(Course).to receive(:all)
      get :index
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_success
    end

    it 'assigns courses to @courses' do
      get :index
      expect(assigns(:courses)).to eq(@courses)
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
    before do
      allow_any_instance_of(Course).to receive(:id).and_return(2)
    end

    context 'with valid attributes' do
      before do
        allow_any_instance_of(Course).to receive(:save).and_return(course)
      end
      it 'saves the new add on in the database' do
        expect_any_instance_of(Course).to receive(:save)
        post :create, params: { course: valid_attributes }
      end

      it 'renders the create template' do
        post :create, params: { course: valid_attributes }
        expect(response).to redirect_to school_courses_path
      end

      it 'assigns the new course to course' do
        post :create, params: { course: valid_attributes }
        expect(assigns(:course)).to be_a_kind_of(Course)
      end
    end

    context 'with invalid attributes' do
      it "doesn't save the new course in the database" do
        expect do
          post :create, params: { course: { email: nil } }
        end.to_not change(Course, :count)
      end

      it 'renders the create template' do
        post :create, params: { course: { email: nil } }
        expect(response).to render_template :new
      end
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: course.to_param }
      expect(response).to be_success
    end
    it 'renders the show template' do
      get :show, params: { id: course.to_param }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { id: course.to_param }
      expect(response).to be_success
    end
    it 'renders the edit template' do
      get :edit, params: { id: course.to_param }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT #update' do
    before do
      allow(Course).to receive(:find).and_return(course)
      allow_any_instance_of(Course).to receive(:id).and_return(2)
    end

    context 'with valid attributes' do
      before do
        allow_any_instance_of(Course).to receive(:update).and_return(true)
      end
      it 'updates course in the database' do
        expect_any_instance_of(Course).to receive(:update)
        put :update, params: { id: 2, course: valid_attributes }
      end

      it 'renders the update template' do
        put :update, params: { id: 2, course: valid_attributes }
        expect(response).to redirect_to school_courses_path
      end

      it 'assigns the course to course' do
        put :update, params: { id: 2, course: valid_attributes }
        expect(assigns(:course)).to be_a_kind_of(Course)
      end
    end

    context 'with invalid attributes' do
      before do
        allow_any_instance_of(Course).to receive(:update).and_return(false)
      end

      it "doesn't save the new course in the database" do
        expect do
          put :update, params: { id: 2, course: { email: nil } }
        end.to_not change(Course, :count)
      end

      it 'renders the update template' do
        put :update, params: { id: 2, course: { email: nil } }
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow(Course).to receive(:find).and_return(course)
      allow(course).to receive(:destroy).and_return(true)
    end

    it 'deletes the course' do
      expect(course).to receive(:destroy)
      delete :destroy, params: { id: 1 }
    end

    it 'redirects to the courses list' do
      delete :destroy, params: { id: 1 }
      expect(response).to redirect_to(school_courses_path)
    end
  end
end
