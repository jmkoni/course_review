# frozen_string_literal: true

task :get_uop_classes do
  urls = [
    ['FILL THIS OUT LATER', 'https://www.uopeople.edu/programs/general-education-requirements-course-catalog/'],
    ['Computer Science', 'https://www.uopeople.edu/programs/cs/degrees/cs-course-catalog/'],
    ['Health Science', 'https://www.uopeople.edu/programs/hs/health-science-course-catalog/'],
    ['Business Administration', 'https://www.uopeople.edu/programs/ba/degrees/ba-course-catalog/']
  ]

  departments = {}
  urls.each do | dep_name, url |
    departments = parse_html(url, dep_name, departments)
  end

  File.open('lib/json/uop-courses.json', 'w') do |f|
    f.write(departments.to_json)
  end
end

def parse_html(url, department, departments)
  results = Nokogiri::HTML(HTTParty.get(url))
  results.css('div.faq_questions').css('div.faq_qa').each do | faq |
    course_name = faq.css('div.faq_question').text.gsub('(Proctored course)', '').strip
    parsed_text = faq.css('div.faq_answer').text[/[A-Z]{2,5}( )\d{4}/].split(" ")
    dep_short = parsed_text[0].strip
    course_num = parsed_text[1].strip
    if departments[dep_short]
      departments[dep_short][:courses][course_num] = course_name unless course_name.nil? || course_num.nil?
    else
      departments[dep_short] = { name: department, courses: { course_num => course_name } }
    end
  end
  departments
end