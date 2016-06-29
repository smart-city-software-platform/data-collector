require 'net/http'
require 'uri'
require 'singleton'

# This class is a singleton publisher to to broadcast messages.
# When a new data is available, the content its sent to the
# feeding third party applications
class Publisher

	include Singleton

  def broadcast(url, channel, msg)
    message = { channel: channel, data: msg }
    uri = URI.parse(url)
    Net::HTTP.post_form(uri, message: message.to_json)
  end

end