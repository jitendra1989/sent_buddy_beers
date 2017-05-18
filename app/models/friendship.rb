class Friendship < ActiveRecord::Base
  # ============================================================================================#
  # This is the model that defines friendships between two users. It's a bit complicated as
  # it basically links a user to a user through this model. Check out the associations in the 
  # user model to see what it's doing on that side
  # 
  # Or for more info: http://railscasts.com/episodes/163-self-referential-association
  # 
  # -tjt
  # ============================================================================================#
  
  # ============================================================================================#
  # The belongs to method sets the relationship between the two users. The 'user' is the 
  # initiator of the friendship request and the friend is the 'recieving user'
  # 
  # -tjt
  # ============================================================================================#  
  belongs_to :user #initiator/owner of friendship
  belongs_to :friend, :class_name => "User" #person being 'friended'
  
  # ============================================================================================#
  # A friendship only works with two users.
  # 
  # -tjt
  # ============================================================================================#    
  validates_presence_of :user_id, :friend_id
  
  # ============================================================================================#
  # This adds an error if the user tries to add himself as a friend. 
  # 
  # -tjt
  # ============================================================================================#    
  validate :cannot_add_self
   
  def cannot_add_self
    errors.add(:base, "Hopefully you are already friends with yourself") if user_id == friend_id
  end


  # ============================================================================================#
  # After we create the friendship we create an additional friendship row in the database to 
  # represent the reciprocal relationship. In laymans terms, a friendship is a two-way street, so
  # therefore we have to make sure the the friendship shows up on both user's accounts.
  # 
  # We could do this with a reverse lookup and return it with the friendships request but I think
  # this may end up in too many SQL requests so have opted to create a bit more database clutter
  # for (hopefully) some time-saving on querying.
  # 
  # -tjt
  # ============================================================================================#     
  after_create :create_reciprocal_friendship!

  def create_reciprocal_friendship!
    friend.friendships.create!(:friend_id => user_id) unless friend.friends.include?(user)
  end

  # ============================================================================================#
  # Just as above, when we destroy a friendship we must destroy it's reciprocal relationship.
  # 
  # -tjt
  # ============================================================================================#  
  after_destroy :destroy_reciprocal_friendship!
  
  def destroy_reciprocal_friendship!
    friendship = Friendship.find_by_user_id_and_friend_id(friend.id, user.id)
    friendship.destroy() unless friendship.nil?
  end
end
