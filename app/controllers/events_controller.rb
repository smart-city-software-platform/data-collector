class EventsController < ApplicationController
  before_action :set_event, only: [:show]

  # GET /events
  def index
    @events = Event.all.includes(:detail)
    
    resource_id = params[:resource_id]
    resource_ids = params[:resource_ids]
    if (resource_id != nil)
      @events = @events.where("resource_id = ?", resource_id)
    elsif (resource_ids != nil && resource_ids.is_a?(Array))
      @events = @events.where("resource_id IN (?)", resource_ids)
    end
    
    if (params[:type] != nil)
      @events = @events.where("type = ?", params[:type])
    end

  end

  # GET /events/1
  def show
    if @status == :record_not_found
      render :json => { :error => "Bad Request: event not found" }, :status => 400      
    else
      render :json => @event
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      begin
        @event = Event.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @status = :record_not_found
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:type, :resource_id, :date)
    end
end
