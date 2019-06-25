# frozen_string_literal: true

task :get_penn_state_classes, [:file_name] do |_task, args|
  file_name = args.fetch(:file_name)
  departments = JSON.parse(File.read(file_name))
  departments.each do |k, v|
    department = Department.create(short_name: k, name: v[:name])
    v[:courses].each do |course_num, course_name|
      Course.create(department: department, number: course_num, name: course_name)
    end
  end
end
