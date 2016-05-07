![Build Status](https://gitlab.com/smart-city-platform/data_collector/badges/master/build.svg)

# README

## Environment Setup

* Install <a href="https://rvm.io/rvm/install">RVM</a>
* Run on terminal: 
  * ```$ rvm install 2.2.0```
  * ```$ rvm install ruby```  
  * ```$ rvm alias create default ruby-2.3.0```
  * ```$ rvm use ruby-2.3.0 --default```
  * If you have any trouble in last step, run ```/bin/bash --login``` and try again
  * ```$ gem install rails --pre --no-ri --no-rdoc```
  * ```$ sudo apt-get install libmysqld-dev libmysqlclient-dev mysql-client```
* In the project directory, run:
  * ```$ gem install bundle```
  * ```$ bundle install```
  * ```$ bundle exec rake db:create```
  * ```$ bundle exec rake db:migrate```
* Run the tests:
  * ```$ rspec```

## Configuration