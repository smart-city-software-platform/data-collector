class SensorValuesController < ApplicationController

  skip_before_action :verify_authenticity_token
  
  def resources_data
  	render :json => {:message => "resources_data not implemented"}
  end

  def resource_data
  	render :json => {:message => "resource_data not implemented"}
  end

  def resources_data_last
  	render :json => {:message => "resources_data_last not implemented"}
  end

  def resource_data_last
  	render :json => {:message => "resource_data_last not implemented"}
  end
end
