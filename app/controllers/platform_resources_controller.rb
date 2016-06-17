class PlatformResourcesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :find_platform_resource, only: [:edit]

  def create
    platform_resource = PlatformResource.new(platform_resource_params)
    if platform_resource.save
      capabilities_hash = capability_params
      capabilities_array = capabilities_hash[:capabilities]
      if capabilities_array.kind_of? Array
        capabilities_array.each do |capability_name|
          capability = Capability.find_or_create_by(name: capability_name)
          platform_resource.capabilities << capability
        end
      end
      render json: {data: platform_resource}, status: 201
    else
      render json: { error: "Internal Server Error" }, status: 500
    end
  end

  def update
    begin
      raise ActiveRecord::RecordNotFound unless @retrieved_resource
      @retrieved_resource.update(platform_resource_params)
      if capability_params
        capabilities_hash = capability_params
        capabilities_array = capability_hash[:capabilities]
        target_to_remove = @retrieved_resource.capabilities
                                .where("name not in (?)", capabilities_array)
        # Removing old capabilities
        @retrieved_resource.capabilities.delete(target_to_remove)

        # Add new capabilities
        if capabilities_array.kind_of? Array
          capabilities_array.each do |capability_name|
            capability = Capability.find_or_create_by(name: capability_name)
            unless @retrieved_resource.capabilities.include?(capability)
              @retrieved_resource.capabilities << capability
            end
          end
        end
        # TODO: Restart data collect
      else
        # TODO: Find right exception
        raise ActiveRecord::RecordNotFound
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: 404
    end
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

end
