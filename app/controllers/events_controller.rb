class EventsController < ApplicationController
  before_filter :authenticate_user!
  layout "new_application"

  def index
    @events = current_user.events
    @upcoming_event = current_user.events.find_comming_events(Date.today + 1.day, Date.today + 16.days).paginate(:per_page => 3, :page => params[:page])
    respond_to do |format|
      format.html
    end
  end

  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    params["event"]["event_type"] = params["event"]["other_event_type"] unless params["event"]["other_event_type"].blank?
    params[:event][:day_of_the_event] = Date.strptime(params[:event][:day_of_the_event], "%m-%d-%Y")
    @event = Event.new(params[:event])
    respond_to do |format|
      if @event.save
        format.json
        format.html { redirect_to events_path, :notice => 'Event was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def return_events
    events = current_user.events
    arr_event = []
    #~ fb_ids = []
    events.each do |event|
      unless event.day_of_the_event.blank?
        hash_event = {}
        hash_event["title"]=event.title
        hash_event["start"]=event.day_of_the_event.strftime("%F")
        hash_event["url"]= new_iou_url(:friend_name => event.title)
        arr_event << hash_event
      end

      #~ unless event.friend_fb_id.blank?
        #~ fb_ids << event.friend_fb_id unless fb_ids.blank?
        #~ fb_ids << event.friend_fb_id unless fb_ids.include? event.friend_fb_id
      #~ end
    end
    if current_user.present? && current_user.friendships.present?
      friends = current_user.friendships
      unless friends.blank?
        friends.each do |freind|
          friend_info = User.where(:id => freind.friend_id).first
          if friend_info.present? && friend_info.birthday_day.present?
            arr_event << set_birthday_calender(friend_info)
          end
        end
      end
    end
    if current_user.present? && current_user.birthday_day.present?
      arr_event << set_birthday_calender(current_user)
    end
    render :json => arr_event
  end

  private
  def set_birthday_calender(user)
    hash_event = {}
    hash_event["title"]=user.get_name
    hash_event["start"]=user.get_formatted_date_to_calender
    hash_event["url"]= new_iou_url(:user_id => user.id)
    return hash_event
  end

   #~ def get_fb_friends
    #~ graph = Koala::Facebook::GraphAPI.new(APP_CONFIG['fb_get_access_token'])
    #~ @friends = graph.get_connections('me', 'friends', :fields => 'email,id,name', :scope => 'email,user_friends,user_events,user_birthday,xmpp_login')
    #~ @friends.sort! { |a,b| a['name'].downcase <=> b['name'].downcase }
  #~ end

end
