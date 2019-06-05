# frozen_string_literal: true

json.extract! review, :id, :course_id, :user_id, :notes, :work_required, :difficulty, :rating, :experience_with_topic, :year, :term, :grade, :created_at, :updated_at
json.url review_url(review, format: :json)
