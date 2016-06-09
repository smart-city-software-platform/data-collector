require 'net/http'

class ResourceWorker
  include Sidekiq::Worker
  attr_accessor :url, :uuid, :timestep

  def perform(uri, uuid, timestep)
    @uuid = uuid
    @timestep = timestep

    begin
      @url = URI.parse(uri + '/' + uuid)
    rescue URI::Error => ex
      puts 'Resource URI error: ' + ex
      return
    end

    get_loop()
  end

  # Using 'GET components/:id' from Resource Adaptor (I suppose ':id' is 'uuid'?)
  def get_loop
    while !cancelled?
      # Do a GET request to the resource url
      request = Net::HTTP::Get.new(@url.to_s)
      response = Net::HTTP.start(@url.host, @url.port) { |http|
        http.request(request)
      }

      # DEBUG!
      puts response.body

      # Update database (stop thread if error occurs)
      resource = Event.find(@uuid)
      return unless resource.update(response)

      # Wait until next GET
      sleep @timestep
  end

  def cancelled?
    true # TODO: Kill thread when PUT event occurs
  end
end
