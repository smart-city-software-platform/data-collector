class PlatformResourcesController < ApplicationController
  skip_before_action :verify_authenticity_token

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
      render :json => { :error => "Internal Server Error" }, :status => 500
    end
  end

  def edit
  end

  private

    def platform_resource_params
      params.require(:data).permit(:uri, :uuid, :status, :collect_interval)
    end

    def capability_params
      params.require(:data).permit(capabilities: [])
    end

end
