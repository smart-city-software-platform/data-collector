![Build Status](https://gitlab.com/smart-city-platform/data_collector/badges/master/build.svg)

# README

## Environment Setup

* Install <a href="https://rvm.io/rvm/install">RVM</a>
* Run on terminal: ```$ rvm install 2.2.0```
* In the project directory, run:
  * ```$ gem install bundle```
  * ```$ bundle install```
  * ```$ bundle exec rake db:create```
  * ```$ bundle exec rake db:migrate```
* Run the tests:
  * ```$ rspec```

## Configuration