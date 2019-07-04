# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# default dev admin
if User.count.zero?
  User.create(email: 'jmkoni@icloud.com', password: '867-J3nny-5309!', password_confirmation: '867-J3nny-5309!', is_admin: true)
end

#default dev regular user
User.create(email: 'heather@koni.com', password: '867-J3nny-5309!', password_confirmation: '867-J3nny-5309!', is_admin: false)

if User.count < 25
  domains = ['course_review.org', 'ponyparty.us', 'unico.rn', 'thecloud.cloud',
             'fat.cats', 'huskyhuskys.dog', 'utumno.lotr', 'taur-im-duinath.org',
             'paths_of_the_dead.com', 'old_forest_road.lotr', 'henneth_annun.org',
             'fens_of_serech.lotr', 'helms_deep.com', 'old_forest.org', 'carchost.lotr']
  names = %w[shadowfax faramir theoden legolas peregrin_took
             barliman_butterbur frodo_baggins saruman_the_white eomer
             aragorn meriadoc_brandybuck treebeard eowyn bilbo_baggins
             tom_bombadil elrond sauron gandalf_the_grey shelob
             samwise_gamgee quickbeam arwen_evenstar gimli gollum
             glorfindel galadriel]

  i = 0
  while i < 25
    if i < 10
      is_admin = [true, false].sample
    else
      is_admin = false
    end

    User.create(email: names.sample + "#{i}@" + domains.sample,
                password: '867-J3nny-5309!',
                password_confirmation: '867-J3nny-5309!',
                is_admin: is_admin,
                confirmed_at: Time.now,
                current_sign_in_ip: "127.0.0.1",
                last_sign_in_ip: "127.0.0.1")
    i += 1
  end
end

9.times do
  school = School.create(name: Faker::University.name, short_name: Faker::Alphanumeric.alpha(3).upcase)
  10.times do
    department = Department.create(name: Faker::Educator.subject,
                                   short_name: Faker::Alphanumeric.alpha(3).upcase,
                                   school: school)
    5.times do
      course = Course.create(name: Faker::Educator.course_name,
                             number: rand(1000).to_s,
                             department: department)
      10.times do
        num = rand(25)
        Review.create(course: course,
                      user: User.find(num + 1),
                      notes: Faker::Lorem.paragraph,
                      work_required: rand(10),
                      difficulty: rand(10),
                      rating: rand(10),
                      experience_with_topic: [true, false].sample,
                      year: rand(2000..2019),
                      term: rand(4),
                      grade: rand(100))
      end
    end
  end
end

