# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  let(:school) { create(:school) }
  let(:course) { create(:course, school: school) }
  let(:valid_attributes) { { name: 'Unicorn Studies 101', department: 'Unicorns', number: '101' } }
  let(:invalid_attributes) { { name: nil, department: nil, number: '101' } }

  before do
    allow(School).to receive(:find).and_return(school)
    allow(Course).to receive(:find).and_return(course)
    allow(course).to receive(:id).and_return(1)
    allow(school).to receive(:id).and_return(1)
  end

  context 'anonymous user' do
    describe 'GET #index' do
      before do
        @courses = [build_stubbed(:course), build_stubbed(:course)]
        allow(Course).to receive(:all).and_return(@courses)
        allow(Course).to receive(:where).and_return(@courses)
      end

      it 'returns a success response' do
        get :index, params: { school_id: 1 }
        expect(response).to be_successful
      end

      it 'renders the index template' do
        get :index, params: { school_id: 1 }
        expect(response).to render_template(:index)
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        expect { get :new, params: { school_id: 1 } }.to raise_error(CanCan::AccessDenied)
        # expect(response).to be_successful
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

    describe 'GET #index' do
      before do
        @courses = [build_stubbed(:course), build_stubbed(:course)]
        allow(Course).to receive(:all).and_return(@courses)
        allow(Course).to receive(:where).and_return(@courses)
      end

      it 'returns a success response' do
        get :index, params: { school_id: 1 }
        expect(response).to be_successful
      end

      it 'renders the index template' do
        get :index, params: { school_id: 1 }
        expect(response).to render_template(:index)
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        expect { get :new, params: { school_id: 1 } }.to raise_error(CanCan::AccessDenied)
        expect(response).to be_successful
      end
    end
  end

  context 'admin user' do
    let(:current_user) { build_stubbed(:admin) }
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

      it 'calls where' do
        expect(Course).to receive(:where)
        get :index, params: { school_id: 1 }
      end

      it 'calls all' do
        expect(Course).to receive(:all)
        get :index, params: { school_id: 'all' }
      end

      it 'returns a success response' do
        get :index, params: { school_id: 1 }
        expect(response).to be_successful
      end

      it 'assigns courses to @courses' do
        get :index, params: { school_id: 1 }
        expect(assigns(:courses)).to eq(@courses)
      end

      it 'renders the index template' do
        get :index, params: { school_id: 1 }
        expect(response).to render_template(:index)
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        get :new, params: { school_id: 1 }
        expect(response).to be_successful
      end
      it 'renders the new template' do
        get :new, params: { school_id: 1 }
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
          post :create, params: { school_id: 1, course: valid_attributes }
        end

        it 'renders the create template' do
          post :create, params: { school_id: 1, course: valid_attributes }
          expect(response).to redirect_to school_course_url(school_id: 1, id: course.id)
        end

        it 'assigns the new course to course' do
          post :create, params: { school_id: 1, course: valid_attributes }
          expect(assigns(:course)).to be_a_kind_of(Course)
        end
      end

      context 'with invalid attributes' do
        it "doesn't save the new course in the database" do
          expect do
            post :create, params: { school_id: 1, course: invalid_attributes }
          end.to_not change(Course, :count)
        end

        it 'renders the create template' do
          post :create, params: { school_id: 1, course: invalid_attributes }
          expect(response).to render_template :new
        end
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        get :show, params: { id: course.id, school_id: school.id }
        expect(response).to be_successful
      end
      it 'renders the show template' do
        get :show, params: { id: course.id, school_id: school.id }
        expect(response).to render_template(:show)
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        get :edit, params: { id: course.id, school_id: school.id }
        expect(response).to be_successful
      end
      it 'renders the edit template' do
        get :edit, params: { id: course.id, school_id: school.id }
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
          put :update, params: { id: 2, school_id: 1, course: valid_attributes }
        end

        it 'renders the update template' do
          put :update, params: { id: 2, school_id: 1, course: valid_attributes }
          expect(response).to redirect_to school_course_url(school_id: 1, id: course.id)
        end

        it 'assigns the course to course' do
          put :update, params: { id: 2, school_id: 1, course: valid_attributes }
          expect(assigns(:course)).to be_a_kind_of(Course)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(Course).to receive(:update).and_return(false)
        end

        it "doesn't save the new course in the database" do
          expect do
            put :update, params: { id: 2, school_id: 1, course: invalid_attributes }
          end.to_not change(Course, :count)
        end

        it 'renders the update template' do
          put :update, params: { id: 2, school_id: 1, course: invalid_attributes }
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
        delete :destroy, params: { id: 1, school_id: 1 }
      end

      it 'redirects to the courses list' do
        delete :destroy, params: { id: 1, school_id: 1 }
        expect(response).to redirect_to(school_courses_path)
      end
    end
  end
end
