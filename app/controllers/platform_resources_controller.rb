class PlatformResourcesController < ApplicationController

  def create
    platform_resource = PlatformResource.new(platform_resource_params)
    if platform_resource.save
      capabilities = capability_params[:capabilities]
      if capabilities.present?
        capabilities.each do |single_capability|
          capability = Capability.find
        end
      end
      render json: platform_resource,
              status: 201, location: platform_resource_url(platform_resources)
    else
      render :json => { :error => "Internal Server Error" }, :status => 500
    end
  end

  def edit
  end

  private

    def platform_resource_params
      params.require(:platform_resource).permit(:uri, :uuid, :status,
                                                :collect_interval)
    end

    def capability_params
      # TODO
    end

end
