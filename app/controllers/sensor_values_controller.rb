class SensorValuesController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :find_platform_resource, only: [:resource_data, :resource_data_last]
  before_action :set_sensor_values, only: [:resources_data, :resource_data]
  before_action :set_sensor_values_last, only: [:resources_data_last, :resource_data_last]
  before_action :filter_by_uuids, only: [:resources_data, :resources_data_last]
  before_action :filter_by_date, :filter_by_capabilities, :filter_by_value

  def set_sensor_values
    @sensor_values = SensorValue.all.includes(:capability)
  end

  def set_sensor_values_last
    @sensor_values = SensorValue.select('DISTINCT ON(capability_id) sensor_values.*')
                                .where('capability_id IS NOT NULL')
                                .order('capability_id, date DESC')
  end

  def filter_by_uuids
    uuids = sensor_value_params[:uuids]
    if !uuids.nil? && uuids.is_a?(Array)
      @ids = PlatformResource.where("uuid IN (?)", uuids).pluck(:id)
      @sensor_values = @sensor_values.where("platform_resource_id IN (?)", @ids)
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
          render json: { error: 'Bad Request: event not found' }, status: 400
          break # Prevents DoubleRenderError ('render' occurring two times)
        end
      end
    end
    unless @start_date.nil?
      @sensor_values = @sensor_values.where("date >= ?", @start_date)
    end
    unless @start_date.nil?
      @sensor_values = @sensor_values.where("date <= ?", @end_date)
    end
  end

  def filter_by_capabilities
    capabilities_name = params[:capabilities]
    if capabilities_name
      ids = Capability.where("name in (?)", capabilities_name).pluck(:id)
      @sensor_values = @sensor_values.where("capability_id in (?)", ids)
    end
  end

  def filter_by_value
    return unless params[:range]

    capability_hash = params[:range]

    capability_hash.each do |capability_name, range_hash|
      capability = Capability.where(name: capability_name)
      if capability
        @sensor_values = @sensor_values.where(capability_id: capability.id)
        min = range_hash['min']
        max = range_hash['max']
        equal = range_hash['equal']
        if equal
          @sensor_values = @sensor_values.where(value: equal)
        else
          if max
            @sensor_values = @sensor_values.where("value <= ?", max)
          end
          if min
            @sensor_values = @sensor_values.where("value >= ?", min)
          end
        end
      end
    end
  end

  # Return all resources with all their capabilities. Finally, each capability
  # has all the historical values associated with it.
  # @note http://localhost:3000/resources/data
  def resources_data
    begin
      generate_response
    rescue Exception
      render json: { error: 'Internal server error' }, status: 500
    end
  end

  def resource_data
    begin
      @sensor_values = @sensor_values.where('platform_resource_id = ?',
                                            @retrieved_resource.id)

      generate_response
    rescue Exception
      render json: { error: 'Internal server error' }, status: 500
    end

  end

  def resources_data_last
    begin
      generate_response
    rescue Exception
      render json: { error: 'Internal server error' }, status: 500
    end

  end

  def resource_data_last
    begin
      @sensor_values.where('platform_resource_id = ?', @retrieved_resource.id)
                    .order('capability_id, date DESC')

      generate_response
    rescue Exception
      render json: { error: 'Internal server error' }, status: 500
    end
  end

  private

    def find_platform_resource
      begin
        @retrieved_resource = PlatformResource.find_by_uuid(params[:uuid])
        raise ActiveRecord::RecordNotFound unless @retrieved_resource

      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Resource not found' }, status: 404
      end
    end

    def sensor_value_params
      params.permit(sensor_value: [:limit, :start, :start_range, :end_range,
                                            :uuid, :range, :capability,
                                            uuids: [], capabilities: []])
      params[:sensor_value] || {}
    end

    def generate_response
      resources = {}
      @sensor_values.each do |value|
        collected = {}
        collected['value'] = value.value
        collected['date'] = value.date

        resource  = resources[value.platform_resource.uuid] || {}
        capabilities = resource['capabilities'] || {}
        capability = capabilities[value.capability.name] || []
        capability << collected

        capabilities[value.capability.name] = capability
        resource['uuid'] = value.platform_resource.uuid
        resource['capabilities'] = capabilities
        resources[value.platform_resource.uuid] = resource
      end

      render json: {resources: resources.values}
    end

    # Notify the client whose are feeding for new resource sensors data
    def broadcast(channel, msg)
      message = {:channel => channel, :data => msg}
      uri = URI.parse("http://#{ request.host }:9292/collector")
      Net::HTTP.post_form(uri, :message => message.to_json)
    end
end
