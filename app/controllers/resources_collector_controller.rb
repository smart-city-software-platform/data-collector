class ResourcesCollectorController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    resource = Event.new(resource_collector_param)
    if resource.save
      render json: resource, status: 201, location: event_url(resource)
    else
      render :json => { :error => "Internal Server Error" }, :status => 500
    end
  end

  def update
    resource = Event.find(params[:id])
    if resource.update(resource_collector_param)
      render json: resource
    else
      render :json => { :error => "Internal Server Error" }, :status => 500
    end
  end

  private

    def resource_collector_param
      params.require(:resources_collector).permit(:resource_id, :date, :category)
    end

end
