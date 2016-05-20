class EventsController < ApplicationController
  before_action :set_event, only: [:show]

  # GET /events
  def index
    @events = Event.all.includes(:detail)

    resource_id = params[:resource_id]
    resource_ids = params[:resource_ids]
    limit = params[:limit]
    start = params[:start]
    capability = params[:capability]

    # Validate 'limit' and 'start' parameters (they must be positive integers)
    [limit, start].each do |arg|
      if !arg.nil? && arg !~ /\A\+?\d+\z/
        render :json => { :error => "Bad Request: event not found" }, :status => 400
        break  # Prevents DoubleRenderError (i.e., 'render' occurring two times)
      end
    end

    @events = @events.limit(limit) unless limit.nil?
    @events = @events.offset(start) unless limit.nil?

    # Search database using provided parameters
    begin
      if (resource_id != nil)
        @events = @events.where("resource_id = ?", resource_id)
      elsif (resource_ids != nil && resource_ids.is_a?(Array))
        @events = @events.where("resource_id IN (?)", resource_ids)
      end
      
      if (capability != nil)
        @events = @events.where(:details => {:capability => capability})
      end

    rescue Exception
      render :json => { :error => "Internal Server Error" }, :status => 500
    end

  end

  # GET /events/:event_id
  def show
    if @status == :record_not_found
      render :json => { :error => "Bad Request: event not found" }, :status => 400
    end
  end

  private
    # Try to get event ID from parameters
    def set_event
      begin
        @event = Event.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @status = :record_not_found
      end
    end

    # Define valid parameters for requests
    def event_params
      params.require(:event).permit(:limit, :start, :resource_id, :capability, resource_ids: [])
    end
end
