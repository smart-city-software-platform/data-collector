require 'rubygems'
require 'thin'
require 'faye'
faye_server = Faye::RackAdapter.new(:mount => '/events/listen', :timeout => 45)
run faye_server