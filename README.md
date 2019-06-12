# Course Review

[![CircleCI](https://circleci.com/gh/jmkoni/course_review/tree/master.svg?style=svg)](https://circleci.com/gh/jmkoni/course_review/tree/master) [![codecov](https://codecov.io/gh/jmkoni/course_review/branch/master/graph/badge.svg)](https://codecov.io/gh/jmkoni/course_review)[![Maintainability](https://api.codeclimate.com/v1/badges/9934c56b219099882c0f/maintainability)](https://codeclimate.com/github/jmkoni/course_review/maintainability)
[![View performance data on Skylight](https://badges.skylight.io/problem/tGkxmMrCXpOV.svg?token=jBiAepV-svm8nuKXXyaN5EVfX1u0fVXDGsTwmZZ9NjU)](https://www.skylight.io/app/applications/tGkxmMrCXpOV)[![View performance data on Skylight](https://badges.skylight.io/typical/tGkxmMrCXpOV.svg?token=jBiAepV-svm8nuKXXyaN5EVfX1u0fVXDGsTwmZZ9NjU)](https://www.skylight.io/app/applications/tGkxmMrCXpOV)[![View performance data on Skylight](https://badges.skylight.io/rpm/tGkxmMrCXpOV.svg?token=jBiAepV-svm8nuKXXyaN5EVfX1u0fVXDGsTwmZZ9NjU)](https://www.skylight.io/app/applications/tGkxmMrCXpOV)[![View performance data on Skylight](https://badges.skylight.io/status/tGkxmMrCXpOV.svg?token=jBiAepV-svm8nuKXXyaN5EVfX1u0fVXDGsTwmZZ9NjU)](https://www.skylight.io/app/applications/tGkxmMrCXpOV)

## Development environment

### Installing Postgres tools locally

Before installing gems, you'll need to ensure that you have PostgreSQL
installed and its utilities on your `PATH`.

This is the recommended way to install on macOS:

Install Postgres.app:

        brew install postgres

Put this line at the bottom of your `.profile`, `.bashrc`, or `.zhshrc` file:

        export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

If you aren't sure which one, add it to all of them!

### Install Ruby

The recommended way to install ruby is to do it via rvm:

        \curl -sSL https://get.rvm.io | bash -s stable --ruby=2.6.3

### Install Dependencies

You'll also need to install the Rubygems that are necessary.

    rvm use 2.6.3@course-review --create
    gem install bundler
    bundle install

NOTE: if you installed ruby using something other than RVM, you want to create a gemset some way so that you don't get conflicts later on.

### Preparing Postgres

Start PostgreSQL using (or your preferred method):

    brew services start postgresql

You'll need to create a user `root` with password `root` and give that user
privileges on two databases: `course-review_development` and `course-review_test`.

Add users:

    createuser course_review --createdb

### Setup the Rails app

Next, setup the database automatically using Rails:

    rails db:setup

Once that completes, you're ready to go!

Note: this will only create a single user. If you want the full set of seeds, run this:

    rails db:seed

To start the server, run:

    rails s

You can leave this server running while you develop. You need only restart the
server when you make changes to anything in the `config` or `db` directories. To view the application, go to `localhost:3000`.

## Developing

This application uses Rspec for tests and Rubocop to enforce style. Prior to pushing up any branch, ensure both are passing by running the following:

    bundle exec rspec # runs specs, should get all green with a few pending
    rubocop -a # should get all green, but if it corrects, it will return a W
    # if rubocop corrects, then make sure to commit the updates!

