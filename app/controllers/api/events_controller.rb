class Api::EventsController < Api::BaseController

  before_filter :authenticate_user_for_api!, :get_user
  before_filter :user_auth_token

  def index_1
    @user = user_auth_token
    if !@user.blank? && !params["auth_token"].blank?
      events = @user.events
      unless events.blank?
        comming_events = events.find_comming_events(Date.today + 1.day, Date.today + 16.days)
        upcoming_events = comming_events.order("day_of_the_event ASC").paginate(:per_page => 3, :page => params[:page])
        render :json => {:success => true, :events => upcoming_events, :total_pages=>comming_events.count, :current_page=> params[:page]}
      else
        render :json => {:success => true, :events => events}
      end
    else
      rescue_from_no_user
    end
  end

  def create_1
    if params["auth_token"].blank?
      render :json => {:success => false, :errors => "auth_token should not be nil"}
    end

    @user = user_auth_token

    if @user.blank?
      render :json => {:success => false, :errors => "Invalid Params"}
    end

    if params["event_type"].blank?
      render :json => {:success => false, :errors => "Event Type should not be nil"}
    end

    if params["title"].blank?
      render :json => {:success => false, :errors => "Event Title should not be nil"}
    end

    if params["day_of_the_event"].blank?
      render :json => {:success => false, :errors => "Event date should not be nil"}
    end

    params[:user_id] = params[:user_id].blank? ? @user.try(:id) : params[:user_id]

    event = Event.new
    event.title = params["title"]
    event.event_type = params["event_type"]
    event.user_id = params["user_id"]
    event.day_of_the_event = Date.strptime(params[:day_of_the_event], "%m-%d-%Y")

    if event.save
      render :json => {:success => "The Event has been created successfully!", :event => event}
    else
      rescue_from_no_user
    end
  end

  private

  def user_auth_token
    User.find_by_authentication_token(params["auth_token"])
  end
end
