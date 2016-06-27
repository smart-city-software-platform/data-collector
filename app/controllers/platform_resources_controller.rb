require_relative '../../lib/worker-manager/worker_supervisor.rb'

# Create and update platform resources. After store data, create a new worker
# to collect data from resource-adaptor.
class PlatformResourcesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :find_platform_resource, only: [:update]

  @supervisor

  def initialize
    @supervisor = WorkerSupervisor.instance
  end

  def create
    platform_resource = PlatformResource.new(platform_resource_params)
    begin
      if platform_resource.save
        capabilities = param_capabilities
        assotiate_capability_with_resource(capabilities, platform_resource)
        # Started worker collect(platform_resource)
        @supervisor.set_resource_as_active(platform_resource.id)
        @supervisor.start_collect(platform_resource.uri, platform_resource.id,
                                 platform_resource.collect_interval)
        render json: { data: platform_resource }, status: 201
      else
        render json: { error: 'Internal Server Error' }, status: 500
      end
    rescue ActiveRecord::RecordNotUnique
      render json: { error: 'Duplicated uuid' }, status: 400
    end
  end

  def update
    raise ActiveRecord::RecordNotFound unless @retrieved_resource
    @retrieved_resource.update!(platform_resource_params)

    capabilities = param_capabilities
    remove_needed_capabilities(capabilities, @retrieved_resource)

    assotiate_capability_with_resource(capabilities, @retrieved_resource)

    render json: { data: @retrieved_resource }, status: 201

    # TODO: Restart data collect thread
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Not found' }, status: 404
  end

  private

  def platform_resource_params
    params.require(:data).permit(:uri, :uuid, :status, :collect_interval)
  end

  def capability_params
    params.require(:data).permit(capabilities: [])
  end

  def find_platform_resource
    @retrieved_resource = PlatformResource.find_by_uuid(params[:uuid])
  end

  def param_capabilities
    capability_params[:capabilities]
  end

  def assotiate_capability_with_resource(capabilities, resource)
    if capabilities.kind_of? Array
      capabilities.each do |capability_name|
        capability = Capability.find_or_create_by(name: capability_name)
        unless resource.capabilities.include?(capability)
          resource.capabilities << capability
        end
      end
    end
  end

  def remove_needed_capabilities(capabilities, resource)
    # If no capabilities are present inside hash, just remove all
    if capabilities.nil?
      resource.capabilities.delete_all
    else
      rm = resource.capabilities.where('name not in (?)', capabilities)
      resource.capabilities.delete(rm)
    end
  end
end
