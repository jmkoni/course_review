# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  let(:school) { create(:school) }
  let(:department) { create(:department, school: school) }
  let(:course) { create(:course, department: department) }
  let(:review) { create(:review, course: course) }
  let(:valid_attributes) { FactoryBot.attributes_for(:review).merge(course_id: course.id) }
  let(:invalid_attributes) { { name: nil, department: nil, number: '101' } }

  context 'anonymous user' do
    describe 'GET #index' do
      before do
        3.times do
          create(:review, course: course)
        end
      end

      it 'returns the right information' do
        get :index, params: { school_id: school.id, department_id: department.id, course_id: course.id }
        aggregate_failures 'specific course and school' do
          expect(response).to be_successful
          expect(response).to render_template(:index)
        end
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        expect { get :new, params: { school_id: school.id, department_id: department.id, course_id: course.id } }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  context 'signed in user' do
    let(:current_user) { create(:user) }
    before do
      sign_in current_user
      allow(request.env['warden']).to receive(:authenticate!).and_return(current_user)
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    describe 'GET #index' do
      before do
        3.times do
          create(:review, course: course)
        end
      end

      it 'returns the right information' do
        get :index, params: { school_id: school.id, department_id: department.id, course_id: course.id }
        aggregate_failures 'specific course and school' do
          expect(response).to be_successful
          expect(response).to render_template(:index)
        end
      end
    end

    describe 'GET #edit' do
      it 'returns an access denied message' do
        expect { get :edit, params: { school_id: school.id, department_id: department.id, course_id: course.id, id: review.id } }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  context 'admin user' do
    let(:current_user) { create(:admin) }
    before do
      sign_in current_user
      allow(request.env['warden']).to receive(:authenticate!).and_return(current_user)
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    describe 'GET #index' do
      before do
        @all_reviews = []
        @course_reviews = []
        @department_reviews = []
        @school_reviews = []
        3.times do
          review = create(:review, course: course)
          @all_reviews << review
          @course_reviews << review
          @department_reviews << review
          @school_reviews << review
        end
        course2 = create(:course, department: department)
        2.times do
          review = create(:review, course: course2)
          @all_reviews << review
          @department_reviews << review
          @school_reviews << review
        end
        school2 = create(:school)
        department2 = create(:department, school: school2)
        course3 = create(:course, department: department2)
        2.times do
          review = create(:review, course: course3)
          @all_reviews << review
        end
      end

      it 'calls all' do
        get :index, params: { school_id: 'all', department_id: 'all', course_id: 'all' }
        aggregate_failures 'validate includes correct reviews' do
          @all_reviews.each do |course_review|
            expect(assigns(:reviews)).to include(course_review)
          end
        end
      end

      it 'calls where for all reviews for a given school' do
        get :index, params: { school_id: school.id, department_id: 'all', course_id: 'all' }
        aggregate_failures 'validate includes correct reviews' do
          @school_reviews.each do |course_review|
            expect(assigns(:reviews)).to include(course_review)
          end
          (@all_reviews - @school_reviews).each do |course_review|
            expect(assigns(:reviews)).not_to include(course_review)
          end
        end
      end

      it 'calls where for all reviews for a given department' do
        get :index, params: { school_id: school.id, department_id: department.id, course_id: 'all' }
        aggregate_failures 'validate includes correct reviews' do
          @department_reviews.each do |course_review|
            expect(assigns(:reviews)).to include(course_review)
          end
          (@all_reviews - @department_reviews).each do |course_review|
            expect(assigns(:reviews)).not_to include(course_review)
          end
        end
      end

      it 'returns a success response' do
        get :index, params: { school_id: school.id, department_id: department.id, course_id: course.id }
        expect(response).to be_successful
      end

      it 'assigns reviews to @reviews' do
        get :index, params: { school_id: school.id, department_id: department.id, course_id: course.id }
        aggregate_failures 'validate includes correct reviews' do
          @course_reviews.each do |course_review|
            expect(assigns(:reviews)).to include(course_review)
          end
          (@all_reviews - @course_reviews).each do |course_review|
            expect(assigns(:reviews)).not_to include(course_review)
          end
        end
      end

      it 'renders the index template' do
        get :index, params: { school_id: school.id, department_id: department.id, course_id: course.id }
        expect(response).to render_template(:index)
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        get :new, params: { school_id: school.id, department_id: department.id, course_id: course.id }
        expect(response).to be_successful
      end
      it 'renders the new template' do
        get :new, params: { school_id: school.id, department_id: department.id, course_id: course.id }
        expect(response).to render_template(:new)
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'saves the new add on in the database' do
          expect_any_instance_of(Review).to receive(:save)
          post :create, params: { school_id: school.id, department_id: department.id, course_id: course.id, review: valid_attributes.merge(user_id: current_user.id) }
        end

        it 'renders the show template' do
          post :create, params: { school_id: school.id, department_id: department.id, course_id: course.id, review: valid_attributes.merge(user_id: current_user.id) }
          last_review = Review.last
          expect(response).to redirect_to school_department_course_review_url(school_id: school.id, department_id: department.id, course_id: course.id, id: last_review.id)
        end

        it 'assigns the new review to review and have the correct values' do
          post :create, params: { school_id: school.id, department_id: department.id, course_id: course.id, review: valid_attributes.merge(user_id: current_user.id) }
          aggregate_failures do
            expect(assigns(:review)).to be_a_kind_of(Review)
            expect(assigns(:review).teacher).to eq valid_attributes[:teacher]
            expect(assigns(:review).grade).to eq valid_attributes[:grade]
            expect(assigns(:review).rating).to eq valid_attributes[:rating]
            expect(assigns(:review).notes).to eq valid_attributes[:notes]
            expect(assigns(:review).work_required).to eq valid_attributes[:work_required]
          end
        end
      end

      context 'with invalid attributes' do
        it "doesn't save the new review in the database" do
          expect do
            post :create, params: { school_id: school.id, department_id: department.id, course_id: course.id, review: invalid_attributes }
          end.to_not change(Review, :count)
        end

        it 'renders the new template' do
          post :create, params: { school_id: school.id, department_id: department.id, course_id: course.id, review: invalid_attributes }
          expect(response).to render_template :new
        end
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        get :show, params: { id: review.id, school_id: school.id, department_id: department.id, course_id: course.id }
        expect(response).to be_successful
      end
      it 'renders the show template' do
        get :show, params: { id: review.id, school_id: school.id, department_id: department.id, course_id: course.id }
        expect(response).to render_template(:show)
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        get :edit, params: { id: review.id, school_id: school.id, department_id: department.id, course_id: course.id }
        expect(response).to be_successful
      end
      it 'renders the edit template' do
        get :edit, params: { id: review.id, school_id: school.id, department_id: department.id, course_id: course.id }
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT #update' do
      context 'with valid attributes' do
        it 'updates review in the database' do
          expect_any_instance_of(Review).to receive(:update)
          put :update, params: { id: review.id, school_id: school.id, department_id: department.id, course_id: course.id, review: valid_attributes }
        end

        it 'renders the update template' do
          put :update, params: { id: review.id, school_id: school.id, department_id: department.id, course_id: course.id, review: valid_attributes }
          expect(response).to redirect_to school_department_course_review_url(school_id: school.id, department_id: department.id, id: review.id)
        end

        it 'assigns the review to review and updated values' do
          aggregate_failures do
            expect(review.teacher).not_to eq valid_attributes[:teacher]
            put :update, params: { id: review.id, school_id: school.id, department_id: department.id, course_id: course.id, review: valid_attributes }
            review.reload
            expect(review.teacher).to eq valid_attributes[:teacher]
            expect(assigns(:review)).to be_a_kind_of(Review)
            expect(assigns(:review).teacher).to eq valid_attributes[:teacher]
            expect(assigns(:review).grade).to eq valid_attributes[:grade]
            expect(assigns(:review).rating).to eq valid_attributes[:rating]
            expect(assigns(:review).notes).to eq valid_attributes[:notes]
            expect(assigns(:review).work_required).to eq valid_attributes[:work_required]
          end
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(Review).to receive(:update).and_return(false)
        end

        it 'renders the update template' do
          put :update, params: { id: review.id, school_id: school.id, department_id: department.id, course_id: course.id, review: invalid_attributes }
          expect(response).to render_template :edit
        end
      end
    end

    describe 'DELETE #destroy' do
      before do
        allow(Review).to receive(:find).and_return(review)
        allow(review).to receive(:destroy).and_return(true)
      end

      it 'deletes the review' do
        expect(review).to receive(:destroy)
        delete :destroy, params: { id: review.id, school_id: school.id, department_id: department.id, course_id: course.id }
      end

      it 'redirects to the reviews list' do
        delete :destroy, params: { id: review.id, school_id: school.id, department_id: department.id, course_id: course.id }
        expect(response).to redirect_to(school_department_course_reviews_path)
      end
    end
  end
end
