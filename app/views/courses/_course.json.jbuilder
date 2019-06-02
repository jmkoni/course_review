# frozen_string_literal: true

json.extract! course, :id, :name, :number, :department, :created_at, :updated_at
json.url course_url(course, format: :json)
