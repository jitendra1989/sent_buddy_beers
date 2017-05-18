class FriendshipsController < ApplicationController
  # ============================================================================================#
  # These actions are for dealing with friendships and creating friendships between users.
  # At the moment theres only a create and destroy actions, plus an index action for listing
  # frienships. This is all we need because there's no need to show or edit friendships at the 
  # moment. Maybe there will be in the future if you want to see history between specific friends
  # or define a friendship as a certain type of relationship
  #
  # More info: http://railscasts.com/episodes/163-self-referential-association
  #
  # Before Filters (located at the bottom of the page under protected):
  #   get_user: get's the current user. At the moment it doesn't make sense to edit other user's
  #             friendships
  #
  # - tjt
  # ============================================================================================#    
  before_filter :authenticate_user!
  before_filter :get_user

  # ============================================================================================#
  # Gets all the current user's friends.
  # 
  # Since we're allowing users to invite new users from their account page we also need to create
  # a new instance of an invitation object.
  # 
  # If the param "?q=something" is passed to the action we only find users who match that query.
  # This is handled by the searchable_by plugin that is set up in each model. We also try 
  # capitalizing and lowercasing the parameter because the query itself is pretty strict.
  # 
  # This action can also be rendered as json which is called for finding friends in the send money
  # form's javascript
  #
  # - tjt
  # ============================================================================================#  
  def index
    @friendships = @user.friendships
    if params[:q]
      @friends = @user.friends.like(params[:q])
    end
    respond_to do |format|
      format.html # index.html.haml
      format.json do
        if @friends
          render :json => @friends.uniq.collect{ |f| {:id => f.id, :name => f.name, :login => f.login, :img_url => f.avatar(:tiny), :email => f.email} } 
        else
          render :json => @friendships 
        end
      end
    end
  end

  # ============================================================================================#
  # Shows the details of a friendship
  # 
  # The content on this page is almost what you'd call a profile for a user's friend. This is 
  # why we're defining the friend instance variable.
  #
  # - tjt
  # ============================================================================================#    
  # def show
  #     @friendship = Friendship.find(params[:id])
  #     @friend = @friendship.friend
  #   end

  # ============================================================================================#
  # Creates a friendship between the current user and the user who's id is passed. As you can 
  # see we're building the friendship from the user's friendships. this automatically applies
  # the current user's id as the use rof the friendship
  # 
  # - tjt
  # ============================================================================================#  
  def create  
    @friendship = @user.friendships.build(:friend_id => params[:friend_id])  
    if @friendship.save  
      flash[:notice] = "Added friend."  
    else  
      flash[:error] = "Error occurred when adding friend."  
    end  
    redirect_to root_url  
  end  

  # ============================================================================================#
  # Destroys a friendship as long as it is found in the current user's friendships. Will error
  # on a nil id but not others like a string. Could probably be re-written a bit cleaner to fail
  # more gracefully but at the moment doesn't cause any real problems.
  # 
  # - tjt
  # ============================================================================================#  
  def destroy  
    if params[:id].nil?
      flash[:error] = "Error ending friendship." 
    else
      @friendship = @user.friendships.find(params[:id])  
      if @friendship and @friendship.destroy  
        flash[:notice] = "Successfully ended friendship."  
      else
        flash[:error] = "Error ending friendship."  
      end
    end
    redirect_to root_url  
  end  
  
protected
  def get_user
    @user = current_user
  end
end
