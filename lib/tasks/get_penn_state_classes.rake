require 'open-uri'

task :get_penn_state_classes, [:level] do |_task, args|
  level = args.fetch(:level)
  url = "https://bulletins.psu.edu/university-course-descriptions/" + level + "/"
  graduate = Nokogiri::HTML(open(url))
  departments = {}
  graduate.css('nav#cl-menu').css('ul.leveltwo').css('li').each do | li |
    parsed_text = li.text.split('(')
    dep_name = parsed_text[0].strip
    dep_short = parsed_text[1].gsub(")","").strip.gsub("- ", "-")
    dep_url = "https://bulletins.psu.edu" + li.css('a')[0]['href']
    departments[dep_short] = { name: dep_name, url: dep_url, courses: {}}
  end

  departments.each do | k, v |
    courses = Nokogiri::HTML(open(v[:url]))
    courses.css('div.course_codetitle').each do | div |
      parsed_text = div.text.split(": ")
      course_num = parsed_text[0].split(" ")[1]
      course_name = parsed_text[1]
      departments[k][:courses][course_num] = course_name unless course_name.nil? || course_num.nil?
    end
  end

  File.open("lib/json/psu-" + level + "-courses.json","w") do |f|
    f.write(departments.to_json)
  end
end