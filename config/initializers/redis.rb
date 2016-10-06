$redis = Redis::Namespace.new('data_collector', :redis => Redis.new(:host => "redis", :port => 6379))
