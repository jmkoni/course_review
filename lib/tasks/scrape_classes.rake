# frozen_string_literal: true
namespace :scrape_classes do
  desc "scrape classes from the penn state website"
  task :penn_state, [:level] do |_task, args|
    level = args.fetch(:level) || 'graduate'
    url = 'https://bulletins.psu.edu/university-course-descriptions/' + level + '/'
    graduate = Nokogiri::HTML(HTTParty.get(url))
    departments = {}
    graduate.css('nav#cl-menu').css('ul.leveltwo').css('li').each do |li|
      parsed_text = li.text.split('(')
      dep_name = parsed_text[0].strip
      dep_short = parsed_text[1].gsub(')', '').strip.gsub('- ', '-')
      dep_url = 'https://bulletins.psu.edu' + li.css('a')[0]['href']
      departments[dep_short] = { name: dep_name, url: dep_url, courses: {} }
    end

    departments.each do |k, v|
      courses = Nokogiri::HTML(HTTParty.get(v[:url]))
      courses.css('div.course_codetitle').each do |div|
        parsed_text = div.text.split(': ')
        course_num = parsed_text[0].split(' ')[1]
        course_name = parsed_text[1]
        departments[k][:courses][course_num] = course_name unless course_name.nil? || course_num.nil?
      end
    end

    File.open('lib/json/psu-' + level + '-courses.json', 'w') do |f|
      f.write(departments.to_json)
    end
  end

  desc "scrape classes from the UOP website"
  task :uop do
    urls = [
      ['FILL THIS OUT LATER', 'https://www.uopeople.edu/programs/general-education-requirements-course-catalog/'],
      ['Computer Science', 'https://www.uopeople.edu/programs/cs/degrees/cs-course-catalog/'],
      ['Health Science', 'https://www.uopeople.edu/programs/hs/health-science-course-catalog/'],
      ['Business Administration', 'https://www.uopeople.edu/programs/ba/degrees/ba-course-catalog/']
    ]

    departments = {}
    urls.each do |dep_name, url|
      departments = parse_html(url, dep_name, departments)
    end

    File.open('lib/json/uop-courses.json', 'w') do |f|
      f.write(departments.to_json)
    end
  end

  def parse_html(url, department, departments)
    results = Nokogiri::HTML(HTTParty.get(url))
    results.css('div.faq_questions').css('div.faq_qa').each do |faq|
      course_name = faq.css('div.faq_question').text.gsub('(Proctored course)', '').strip
      parsed_text = faq.css('div.faq_answer').text[/[A-Z]{2,5}( )\d{4}/].split(' ')
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

  desc 'parse scraped files and add to the system'
  task :parse_json_courses, [:file_name, :school_short_name] => :environment do |_task, args|
    file_name = args.fetch(:file_name)
    school_short_name = args.fetch(:school_short_name)
    school = School.find_by_short_name(school_short_name)
    departments = JSON.parse(File.read("#{Rails.root}/lib/" + file_name))
    departments.each do |k, v|
      department = Department.find_or_create_by(short_name: k, name: v["name"], school: school)
      v["courses"].each do |course_num, course_name|
        Course.find_or_create_by(department: department, number: course_num, name: course_name)
      end
    end
  end
end

# be rails "scrape_classes:parse_json_courses[json/uop-courses.json, UOP]"
