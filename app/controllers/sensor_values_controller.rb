class SensorValuesController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :find_platform_resource, only: [:resource_data, :resource_data_last]
  before_action :set_sensor_values, only: [:resources_data, :resource_data]
  before_action :set_sensor_values_last, only: [:resources_data_last, :resource_data_last]
  before_action :filter_by_uuids, only: [:resources_data, :resources_data_last]
  before_action :filter_by_date

  def set_sensor_values
    @sensor_values = SensorValue.all
  end

  def set_sensor_values_last
    @sensor_values = SensorValue.select('DISTINCT ON(capability_id) sensor_values.*')
  end

  def filter_by_uuids
    uuids = params[:uuids]
    if !uuids.nil? && uuids.is_a?(Array)
      @ids = PlatformResource.where("uuid IN (?)", uuids).pluck(:id)
      @sensor_values.where("platform_resource_id IN (?)", @ids)
    end
  end

  def filter_by_date
    @start_date = params[:start_range]
    @end_date = params[:end_range]

    # Validate 'start_date' and 'end_date' as DateTimes
    [@start_date, @end_date].each do |arg|
      if !arg.nil?
        begin
          DateTime.parse(arg)
        rescue
          render :json => { :error => "Bad Request: event not found" }, :status => 400
          break # Prevents DoubleRenderError ('render' occurring two times)
        end
      end
    end

    @sensor_values.where("date >= ?", @start_date) unless @start_date.nil?
    @sensor_values.where("date <= ?", @end_date) unless @start_date.nil?
  end

  def filter_by_capabilities
    #capabilities_name = JSON[capabilities_value]
    #if capabilities_name
    #ids = Capability.where("name in (?)", capabilities_name).pluck(:id)
    #@sensor_values.where("capability_id in (?)", ids)
    #end
  end

  def resources_data    
    generate_response
  end

  def resource_data
    begin
      raise ActiveRecord::RecordNotFound unless @retrieved_resource

      @sensor_values.where('platform_resource_id = ?', @retrieved_resource.id)
      				.where('capability_id IS NOT NULL')

      generate_response
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Resource not found' }, status: 404
    rescue Exception
      render json: { error: 'Internal server error' }, status: 500
    end

  end

  def resources_data_last
    begin
      @sensor_values.where('capability_id IS NOT NULL')
                    .order('capability_id, date DESC')
    
      generate_response
    rescue Exception
      render json: { error: 'Internal server error' }, status: 500
    end

  end

  def resource_data_last
    begin
      raise ActiveRecord::RecordNotFound unless @retrieved_resource

      @sensor_values.where('platform_resource_id = ?', @retrieved_resource.id)
                    .order('capability_id, date DESC')

      generate_response
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
      params.require(:sensor_value)
            .permit(:limit, :start, :start_range, :end_range, :uuid, :capability, uuids: [])
    end

    def generate_response
      response = []
      @sensor_values.each do |value|
                build_value = {}
                build_value['value'] = value.value
                build_value['date'] = value.date
                build_value['capability'] = value.capability.name
                response << build_value
      end

      render json: {data: response}
    end

    # Notify the client whose are feeding for new resource sensors data
    def broadcast(channel, msg)
      message = {:channel => channel, :data => msg}
      uri = URI.parse("http://#{ request.host }:9292/collector")
      Net::HTTP.post_form(uri, :message => message.to_json)
    end
end
