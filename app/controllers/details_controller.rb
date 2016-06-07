class DetailsController < ApplicationController

  before_action :set_event
  before_action :set_detail, only: [:show]

  def index
    check_filter_id

    begin
      @details = @event.detail
    rescue  Exception
      render :json => { :error => "Internal Server Error" }, :status => 500
    end
  end

  def show
    check_filter_id
  end

  def check_filter_id
    if @status == :record_not_found
      render :json => { :error => "Bad Request: event/detail not found" }, :status => 400
    end
  end

  private
    def set_event
      begin
        @event = Event.find(params[:event_id])
      rescue ActiveRecord::RecordNotFound
        @status = :record_not_found
      end
    end

    def set_detail
      begin
        # check for previous event search success
        if @status != :record_not_found
          @detail = Detail.find(params[:id])
        end
      rescue ActiveRecord::RecordNotFound
        @status = :record_not_found
      end
    end

end
