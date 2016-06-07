class EventsController < ApplicationController
  before_action :set_event, only: [:show]

  # GET /events
  def index
    @events = Event.all.includes(:detail)

    resource_uuid = params[:resource_uuid]
    resource_uuids = params[:resource_uuids]
    limit = params[:limit]
    start = params[:start]
    capability = params[:capability]
    start_range = params[:start_range]
    end_range = params[:end_range]

    # Validate 'start_range' and 'end_range' as DateTimes
    [start_range,end_range].each do |arg|
      if !arg.nil?
        begin
          DateTime.parse(arg)
        rescue
          render :json => { :error => "Bad Request: event not found" }, :status => 400
          break # Prevents DoubleRenderError ('render' occurring two times)
        end
      end
    end

    # Validate 'limit' and 'start' parameters (they must be positive integers)
    [limit, start].each do |arg|
      if !arg.nil? && arg !~ /\A\+?\d+\z/
        render :json => { :error => "Bad Request: event not found" }, :status => 400
        break # Prevents DoubleRenderError
      end
    end

    # Search database using provided parameters
    begin
      @events = @events.limit(limit) unless limit.nil?
      @events = @events.offset(start) unless limit.nil?

      @events = @events.where("date >= ?", start_range) unless start_range.nil?
      @events = @events.where("date <= ?",end_range) unless end_range.nil?

      if !resource_uuid.nil?
        @events = @events.where("resource_uuid = ?", resource_uuid)
      elsif !resource_uuids.nil? && resource_uuids.is_a?(Array)
        @events = @events.where("resource_uuid IN (?)", resource_uuids)
      end

      if !capability.nil?
        @events = @events.where(:details => {:capability => capability})
      end

    rescue Exception
      render :json => { :error => "Internal Server Error" }, :status => 500
    end

  end

  # GET /events/:event_id
  def show
    if @status == :record_not_found
      render :json => { :error => "Bad Request: event not found" },
             :status => 400
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
      params.require(:event).permit(:limit, :start, :resource_uuid, :capability,
                                    resource_uuids: [])
    end
end
