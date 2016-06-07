require 'rubygems'
require 'thin'
require 'faye'
faye_server = Faye::RackAdapter.new(:mount => '/collector', :timeout => 45)
run faye_server