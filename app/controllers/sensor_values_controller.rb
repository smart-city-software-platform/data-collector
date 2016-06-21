class SensorValuesController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :find_platform_resource, only: [:resource_data, :resource_data_last]

  def resources_data
    @sensor_values = SensorValue.all.includes(:capability)
  	render :json => @sensor_values
  end

  def resource_data
    begin
      raise ActiveRecord::RecordNotFound unless @retrieved_resource

      capability_hash = {}
      @sensor_values = SensorValue.where('platform_resource_id = ?',
																					@retrieved_resource.id).where('capability_id IS NOT NULL')
      all_capabilities = Capability.where('id in (?)', @sensor_values.pluck(:capability_id).uniq)
      all_capabilities.map { |cap| capability_hash[cap.id] = cap.name}

      response = []
      @sensor_values.find_each do |value|
				build_value = {}
				build_value['value'] = value.value
				build_value['date'] = value.date
				build_value['capability'] = capability_hash[value.capability_id]
				response << build_value
      end

  	  render json: {data: response}

    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Resource not found' }, status: 404
    #rescue Exception
    #  render json: { error: 'Internal server error' }, status: 500
    end

  end

  def resources_data_last
  	render :json => {:message => "resources_data_last not implemented"}
  end

  def resource_data_last
    begin
      raise ActiveRecord::RecordNotFound unless @retrieved_resource

      @sensor_values = SensorValue.select('DISTINCT ON(capability_id) sensor_values.*')
                          .where('platform_resource_id = ?', @retrieved_resource.id)
                          .order('capability_id, date DESC')

      render :json => @sensor_values

    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Resource not found' }, status: 404
    rescue Exception
      render json: { error: 'Internal server error' }, status: 500
    end
  end

  private

    def find_platform_resource
      @retrieved_resource = PlatformResource.find_by_uuid(params[:uuid])
    end

    def sensor_value_params
      params.require(:sensor_value).permit(:limit, :start, :uuid, :capability, uuids: [])
    end

    # Notify the client whose are feeding for new resource sensors data
    def broadcast(channel, msg)
      message = {:channel => channel, :data => msg}
      uri = URI.parse("http://#{ request.host }:9292/collector")
      Net::HTTP.post_form(uri, :message => message.to_json)
    end
end
