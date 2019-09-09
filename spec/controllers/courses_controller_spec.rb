# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  let(:school) { create(:school) }
  let(:department) { create(:department, school: school) }
  let(:department2) { create(:department, school: school) }
  let(:course) { create(:course, department: department) }
  let(:valid_attributes) { { name: 'Unicorn Studies 101', number: '101', department_id: department.id } }
  let(:invalid_attributes) { { name: nil, number: '101' } }

  context 'anonymous user' do
    describe 'GET #index' do
      before do
        3.times do
          create(:course, department: department)
        end
      end

      it 'returns a success response' do
        get :index, params: { school_id: school.id, department_id: department.id }
        expect(response).to be_successful
      end

      it 'renders the index template' do
        get :index, params: { school_id: school.id, department_id: department.id }
        expect(response).to render_template(:index)
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        expect { get :new, params: { school_id: school.id, department_id: department.id } }.to raise_error(CanCan::AccessDenied)
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
        3.times do
          create(:course, department: department)
        end
      end

      it 'returns a success response' do
        get :index, params: { school_id: school.id, department_id: department.id }
        expect(response).to be_successful
      end

      it 'renders the index template' do
        get :index, params: { school_id: school.id, department_id: department.id }
        expect(response).to render_template(:index)
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        expect { get :new, params: { school_id: school.id, department_id: department.id } }.to raise_error(CanCan::AccessDenied)
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
        3.times do
          create(:course, department: department)
        end
        2.times do
          create(:course, department: department2)
        end
        2.times do
          create(:course)
        end
      end

      it 'gets courses for department' do
        get :index, params: { school_id: school.id, department_id: department.id }
        expect(assigns(:courses).length).to eq(3)
      end

      it 'gets courses for school' do
        get :index, params: { school_id: school.id, department_id: 'all' }
        expect(assigns(:courses).length).to eq(5)
      end

      it 'gets all courses' do
        get :index, params: { school_id: 'all', department_id: 'all' }
        expect(assigns(:courses).length).to eq(7)
      end

      it 'returns a success response' do
        get :index, params: { school_id: school.id, department_id: department.id }
        expect(response).to be_successful
      end

      it 'renders the index template' do
        get :index, params: { school_id: school.id, department_id: department.id }
        expect(response).to render_template(:index)
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        get :new, params: { school_id: school.id, department_id: department.id }
        expect(response).to be_successful
      end
      it 'renders the new template' do
        get :new, params: { school_id: school.id, department_id: department.id }
        expect(response).to render_template(:new)
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'saves the new add on in the database' do
          expect_any_instance_of(Course).to receive(:save)
          post :create, params: { school_id: school.id, department_id: department.id, course: valid_attributes }
        end

        it 'renders the create template' do
          post :create, params: { school_id: school.id, department_id: department.id, course: valid_attributes }
          expect(response).to redirect_to school_department_course_url(school_id: school.id,
                                                                       department_id: department.id,
                                                                       id: Course.last.id)
        end

        it 'assigns the new course to course' do
          post :create, params: { school_id: school.id, department_id: department.id, course: valid_attributes }
          expect(assigns(:course)).to be_a_kind_of(Course)
        end
      end

      context 'with invalid attributes' do
        it "doesn't save the new course in the database" do
          expect do
            post :create, params: { school_id: school.id, department_id: department.id, course: invalid_attributes }
          end.to_not change(Course, :count)
        end

        it 'renders the create template' do
          post :create, params: { school_id: school.id, department_id: department.id, course: invalid_attributes }
          expect(response).to render_template :new
        end
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        get :show, params: { id: course.id, school_id: school.id, department_id: department.id }
        expect(response).to be_successful
      end
      it 'renders the show template' do
        get :show, params: { id: course.id, school_id: school.id, department_id: department.id }
        expect(response).to render_template(:show)
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        get :edit, params: { id: course.id, school_id: school.id, department_id: department.id }
        expect(response).to be_successful
      end
      it 'renders the edit template' do
        get :edit, params: { id: course.id, school_id: school.id, department_id: department.id }
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT #update' do
      context 'with valid attributes' do
        before do
          allow_any_instance_of(Course).to receive(:update).and_return(true)
        end
        it 'updates course in the database' do
          expect_any_instance_of(Course).to receive(:update)
          put :update, params: { id: course.id, school_id: school.id, department_id: department.id, course: valid_attributes }
        end

        it 'renders the update template' do
          put :update, params: { id: course.id, school_id: school.id, department_id: department.id, course: valid_attributes }
          expect(response).to redirect_to school_department_course_url(school_id: school.id,
                                                                       department_id: department.id,
                                                                       id: course.id)
        end

        it 'assigns the course to course' do
          put :update, params: { id: course.id, school_id: school.id, department_id: department.id, course: valid_attributes }
          expect(assigns(:course)).to be_a_kind_of(Course)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(Course).to receive(:update).and_return(false)
        end

        it 'renders the update template' do
          put :update, params: { id: course.id, school_id: school.id, department_id: department.id, course: invalid_attributes }
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
        delete :destroy, params: { id: course.id, school_id: school.id, department_id: department.id }
      end

      it 'redirects to the courses list' do
        delete :destroy, params: { id: course.id, school_id: school.id, department_id: department.id }
        expect(response).to redirect_to(school_department_courses_path)
      end
    end
  end
end
