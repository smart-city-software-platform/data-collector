![Build Status](https://gitlab.com/smart-city-platform/data_collector/badges/master/build.svg)

# README

## Git Configuration
* Setup a <a href="https://gitlab.com/profile/keys" target="_blank">ssh key</a>
* In your development machine:
  * ```$ sudo apt-get install git```
  * ```$ git clone git@gitlab.com:smart-city-platform/data_collector.git```
  * ```$ cd data_collector```
  * ```$ git config user.name "Your Username"```
  * ```$ git config user.email "your@mail.com"```
  

## Environment Setup

* Install <a href="https://rvm.io/rvm/install" target="_blank">RVM</a>. Instructions bellow:
  * ```$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3```
  * ```$ \curl -sSL https://get.rvm.io | bash -s stable```
  * ```$ source /home/<your_username>/.rvm/scripts/rvm```
* Run on terminal: 
  * ```$ rvm install 2.2.0```
  * ```$ rvm install ruby```  
  * ```$ rvm alias create default ruby-2.3.0```
  * ```$ rvm use ruby-2.3.0 --default```
  * If you have any trouble in last step, run ```/bin/bash --login``` and try again
  * ```$ gem install rails --pre --no-ri --no-rdoc```
  * ```$ sudo apt-get install mysql-server``` use 'admin' as development password
  * ```$ sudo apt-get install nodejs```
* In the project directory, run:
  * ```$ gem install bundle```
  * ```$ bundle install```
  * ```$ bundle exec rake db:create```
  * ```$ bundle exec rake db:migrate```
* Run the tests:
  * ```$ rspec```

## How to commit your changes?

* Code your tests, make your changes, run and commit
  * ```$ git add <path_to_file>```. Repeat for other files or ```$ git add --all``` for all files
  * ```$ git commit -s -m "Commit message"```
  * ```$ git push origin master:<new branch>```. This will create a remote branch in gitlab with your changes. There you can create a 'Merge Request' to review and integrate your change into master branch.