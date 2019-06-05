# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  let(:school) { create(:school) }
  let(:course) { create(:course, school: school) }
  let(:review) { create(:review, course: course) }
  let(:valid_attributes) { { name: 'Unicorn Studies 101', department: 'Unicorns', number: '101' } }
  let(:invalid_attributes) { { name: nil, department: nil, number: '101' } }

  before do
    allow(School).to receive(:find).and_return(school)
    allow(Course).to receive(:find).and_return(course)
    allow(Review).to receive(:find).and_return(review)
    allow(review).to receive(:id).and_return(1)
    allow(course).to receive(:id).and_return(1)
    allow(school).to receive(:id).and_return(1)
  end

  context 'anonymous user' do
    describe 'GET #index' do
      before do
        @reviews = [build_stubbed(:review), build_stubbed(:review)]
        allow(Review).to receive(:all).and_return(@reviews)
        allow(Review).to receive(:where).and_return(@reviews)
      end

      it 'returns the right information' do
        get :index, params: { school_id: 1, course_id: 1 }
        aggregate_failures 'specific course and school' do
          expect(response).to be_successful
          expect(response).to render_template(:index)
        end
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        expect { get :new, params: { school_id: 1, course_id: 1 } }.to raise_error(CanCan::AccessDenied)
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
        @reviews = [build_stubbed(:review), build_stubbed(:review)]
        allow(Review).to receive(:all).and_return(@reviews)
        allow(Review).to receive(:where).and_return(@reviews)
      end

      it 'returns the right information' do
        get :index, params: { school_id: 1, course_id: 1 }
        aggregate_failures 'specific course and school' do
          expect(response).to be_successful
          expect(response).to render_template(:index)
        end
      end
    end

    describe 'GET #edit' do
      it 'returns an access denied message' do
        expect { get :edit, params: { school_id: 1, course_id: 1, id: 1 } }.to raise_error(CanCan::AccessDenied)
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
        @reviews = [build_stubbed(:review), build_stubbed(:review)]
        allow(Review).to receive(:all).and_return(@reviews)
        allow(Review).to receive(:where).and_return(@reviews)
      end

      it 'calls where' do
        expect(Review).to receive(:where)
        get :index, params: { school_id: 1, course_id: 1 }
      end

      it 'calls all' do
        expect(Review).to receive(:all)
        get :index, params: { school_id: 'all', course_id: 'all' }
      end

      it 'calls where for all reviews for a given school' do
        expect(Review).to receive(:where)
        get :index, params: { school_id: 1, course_id: 'all' }
      end

      it 'returns a success response' do
        get :index, params: { school_id: 1, course_id: 1 }
        expect(response).to be_successful
      end

      it 'assigns reviews to @reviews' do
        get :index, params: { school_id: 1, course_id: 1 }
        expect(assigns(:reviews)).to eq(@reviews)
      end

      it 'renders the index template' do
        get :index, params: { school_id: 1, course_id: 1 }
        expect(response).to render_template(:index)
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        get :new, params: { school_id: 1, course_id: 1 }
        expect(response).to be_successful
      end
      it 'renders the new template' do
        get :new, params: { school_id: 1, course_id: 1 }
        expect(response).to render_template(:new)
      end
    end

    describe 'POST #create' do
      before do
        allow_any_instance_of(Review).to receive(:id).and_return(2)
      end

      context 'with valid attributes' do
        before do
          allow_any_instance_of(Review).to receive(:save).and_return(review)
        end
        it 'saves the new add on in the database' do
          expect_any_instance_of(Review).to receive(:save)
          post :create, params: { school_id: 1, course_id: 1, review: valid_attributes }
        end

        it 'renders the create template' do
          post :create, params: { school_id: 1, course_id: 1, review: valid_attributes }
          expect(response).to redirect_to school_course_review_url(school_id: 1, id: review.id)
        end

        it 'assigns the new review to review' do
          post :create, params: { school_id: 1, course_id: 1, review: valid_attributes }
          expect(assigns(:review)).to be_a_kind_of(Review)
        end
      end

      context 'with invalid attributes' do
        it "doesn't save the new review in the database" do
          expect do
            post :create, params: { school_id: 1, course_id: 1, review: invalid_attributes }
          end.to_not change(Review, :count)
        end

        it 'renders the create template' do
          post :create, params: { school_id: 1, course_id: 1, review: invalid_attributes }
          expect(response).to render_template :new
        end
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        get :show, params: { id: review.id, school_id: school.id, course_id: course.id }
        expect(response).to be_successful
      end
      it 'renders the show template' do
        get :show, params: { id: review.id, school_id: school.id, course_id: course.id }
        expect(response).to render_template(:show)
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        get :edit, params: { id: review.id, school_id: school.id, course_id: course.id }
        expect(response).to be_successful
      end
      it 'renders the edit template' do
        get :edit, params: { id: review.id, school_id: school.id, course_id: course.id }
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT #update' do
      before do
        allow(Review).to receive(:find).and_return(review)
        allow_any_instance_of(Review).to receive(:id).and_return(2)
      end

      context 'with valid attributes' do
        before do
          allow_any_instance_of(Review).to receive(:update).and_return(true)
        end
        it 'updates review in the database' do
          expect_any_instance_of(Review).to receive(:update)
          put :update, params: { id: 2, school_id: 1, course_id: 1, review: valid_attributes }
        end

        it 'renders the update template' do
          put :update, params: { id: 2, school_id: 1, course_id: 1, review: valid_attributes }
          expect(response).to redirect_to school_course_review_url(school_id: 1, id: review.id)
        end

        it 'assigns the review to review' do
          put :update, params: { id: 2, school_id: 1, course_id: 1, review: valid_attributes }
          expect(assigns(:review)).to be_a_kind_of(Review)
        end
      end

      context 'with invalid attributes' do
        before do
          allow_any_instance_of(Review).to receive(:update).and_return(false)
        end

        it "doesn't save the new review in the database" do
          expect do
            put :update, params: { id: 2, school_id: 1, course_id: 1, review: invalid_attributes }
          end.to_not change(Review, :count)
        end

        it 'renders the update template' do
          put :update, params: { id: 2, school_id: 1, course_id: 1, review: invalid_attributes }
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
        delete :destroy, params: { id: 1, school_id: 1, course_id: 1 }
      end

      it 'redirects to the reviews list' do
        delete :destroy, params: { id: 1, school_id: 1, course_id: 1 }
        expect(response).to redirect_to(school_course_reviews_path)
      end
    end
  end
end
