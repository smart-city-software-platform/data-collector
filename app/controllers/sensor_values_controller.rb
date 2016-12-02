# frozen_string_literal: true
# Responsible for returning and filtering sensor values
class SensorValuesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :find_platform_resource,
                only: [:resource_data, :resource_data_last]
  before_action :set_sensor_values,
                only: [:resources_data, :resource_data]
  before_action :set_sensor_values_last,
                only: [:resources_data_last, :resource_data_last]
  before_action :filter_by_uuids, only: [:resources_data, :resources_data_last]
  before_action :filter_by_date, :filter_by_capabilities, :filter_by_value

  def set_sensor_values
    @sensor_values = SensorValue.all.includes(:capability)

    paginate
  end

  def set_sensor_values_last
    @sensor_values = LastSensorValue.all.includes(:capability)

    paginate
  end

  def paginate
    # Validate 'limit' and 'start' parameters (they must be positive integers)
    # and asserts that limit is less than or equal to 1000
    limit = params[:limit] || '1000'
    start = params[:start] || '0'
    limit = '1000' unless limit.to_i <= 1000

    [limit, start].each do |arg|
      next unless !arg.nil? && !arg.is_positive_int?
      render json: { error: 'Bad Request: pagination args not valid' },
             status: 400
      break # Prevents DoubleRenderError
    end

    @sensor_values = @sensor_values.limit(limit) unless limit.nil?
    @sensor_values = @sensor_values.offset(start) unless start.nil?
  end

  def filter_by_uuids
    uuids = sensor_value_params[:uuids]
    return nil if uuids.nil? || !uuids.is_a?(Array)
    ids = PlatformResource.where('uuid IN (?)', uuids).pluck(:id)
    @sensor_values = @sensor_values.where('platform_resource_id IN (?)', ids)
  end

  def filter_by_date
    @start_date = params[:start_range]
    @end_date = params[:end_range]

    # Validate 'start_date' and 'end_date' as DateTimes
    [@start_date, @end_date].each do |arg|
      next if arg.nil?
      begin
        DateTime.parse(arg)
      rescue
        render json: { error: 'Bad Request: resource not found' }, status: 400
        break # Prevents DoubleRenderError ('render' occurring two times)
      end
    end
    unless @start_date.nil?
      @sensor_values = @sensor_values.where('date >= ?', @start_date)
    end
    return nil if @end_date.nil?
    @sensor_values = @sensor_values.where('date <= ?', @end_date)
  end

  def filter_by_capabilities
    capabilities_name = sensor_value_params[:capabilities]
    return nil unless capabilities_name
    ids = Capability.where('name in (?)', capabilities_name).pluck(:id)
    @sensor_values = @sensor_values.where('capability_id in (?)', ids)
  end

  def filter_by_value
    return unless sensor_value_params[:range]

    capability_hash = sensor_value_params[:range]
    sensor_trim = nil
    capability_hash.each do |capability_name, range_hash|
      capability = Capability.find_by_name(capability_name)
      next unless capability

      cap_values = @sensor_values.where('capability_id = ?', capability.id)
      equal = range_hash['equal']
      if !equal.blank?
        cap_values = cap_values.where(value: equal)
        sensor_trim = concat_value(sensor_trim, cap_values)
      else
        min = range_hash['min']
        max = range_hash['max']
        filtered = false
        if !max.blank? && max.is_float?
          cap_values = cap_values.where(' f_value <= ?', max)
          filtered = true
        end
        if !min.blank? && min.is_float?
          filtered = true
          cap_values = cap_values.where(' f_value >= ?', min)
        end
        sensor_trim = concat_value(sensor_trim, cap_values) if filtered
      end
    end

    if !sensor_trim.blank?
      @sensor_values = SensorValue.where(id: sensor_trim.pluck(:id))
    else
      @sensor_values = SensorValue.limit(0)
    end
  end

  def concat_value(sensor_trim, cap_values)
    if sensor_trim.nil?
      cap_values
    else
      sensor_trim | cap_values
    end
  end

  # Return all resources with all their capabilities. Finally, each capability
  # has all the historical values associated with it.
  # @note http://localhost:3000/resources/data
  def resources_data
    generate_response
  end

  def resource_data
    @sensor_values = @sensor_values.where('platform_resource_id = ?',
                                          @retrieved_resource.id)
    generate_response
  end

  def resources_data_last
    generate_response
  end

  def resource_data_last
    @sensor_values = @sensor_values.where('platform_resource_id = ?',
                                          @retrieved_resource.id)
    generate_response
  end

  private

  def find_platform_resource
    begin
      # params[:uuid] gets from the uri, while sensor_value_params gets
      # it from the json sent
      @retrieved_resource = PlatformResource.find_by_uuid(params[:uuid])
      raise ActiveRecord::RecordNotFound unless @retrieved_resource

    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Resource not found' }, status: 404
    end
  end

  def sensor_value_params
    params.permit(sensor_value: [:limit, :start, :start_range, :end_range,
                                 :uuid, range: {}, uuids: [], capabilities: []])
    params[:sensor_value] || {}
  end

  def generate_response
    resources = {}
    begin
      @sensor_values.each do |value|
        collected = {}
        collected['value'] = value.value
        collected['date'] = value.date

        resource = resources[value.platform_resource.uuid] || {}
        capabilities = resource['capabilities'] || {}
        capability = capabilities[value.capability.name] || []
        capability << collected

        capabilities[value.capability.name] = capability
        resource['uuid'] = value.platform_resource.uuid
        resource['capabilities'] = capabilities
        resources[value.platform_resource.uuid] = resource
      end
      render json: { resources: resources.values }
    rescue Exception
      render json: { error: 'Internal Server Error' }, status: 500
    end
  end
end
