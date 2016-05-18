class EventsController < ApplicationController
  before_action :set_event, only: [:show]

  # GET /events
  def index
    @events = Event.all.includes(:detail)

    # Read parameters from request
    resource_id = params[:resource_id]
    resource_ids = params[:resource_ids]
    limit = params[:limit]
    start = params[:start]

    # Validate 'limit' and 'start' parameters (they must be positive integers)
    [limit, start].each do |arg|
      if !arg.nil? && arg !~ /\A\+?\d+\z/
        render :json => { :error => "Bad Request: event not found" }, :status => 400
        break  # Prevents DoubleRenderError
      end
    end

    # Set pagination limit (how many events will be returned)
    @events = @events.limit(limit) unless limit.nil?
    # Set pagination limit and offset (index of first event to be returned)
    @events = @events.offset(start) unless limit.nil?

    begin
      if (resource_id != nil)
        @events = @events.where("resource_id = ?", resource_id)
      elsif (resource_ids != nil && resource_ids.is_a?(Array))
        @events = @events.where("resource_id IN (?)", resource_ids)
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
      params.require(:event).permit(:limit, :start, :resource_id, resource_ids: [])
    end
end
