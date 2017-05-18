class FacebookRequest < ActiveRecord::Base
  
  belongs_to :sender, :class_name => "User", :foreign_key => :facebook_uid
  belongs_to :recipient, :class_name => "User", :foreign_key => :facebook_uid
  belongs_to :iou
  belongs_to :group_drink
  
  scope :closable, lambda { where(:open => true) }
  
  validates_presence_of :sender_id, :recipient_id, :iou_id
  
  after_create :make_request
  
  
  def access_token
    token_url = "https://graph.facebook.com/oauth/access_token?client_id=#{iou.site.facebook_app_id}&client_secret=#{iou.site.facebook_app_secret}&grant_type=client_credentials"
    fb_access_token = HTTParty.get(token_url).body
    return fb_access_token.split("access_token=").last
  end
  
  def make_request
    message = I18n.t("facebook.orders.create.fb_app_request.default_meassage", :name => iou.sender_name)
    title = I18n.t("facebook.orders.create.fb_app_request.title", :beer => [iou.quantity, iou.price_name].join(" "), :bar => iou.bar.name, :city => iou.bar.city.name)
    apprequest_url = "https://graph.facebook.com/#{recipient_id}/apprequests"
    result = HTTParty.post(apprequest_url, :body => {:message => message, :title => title, :access_token => access_token}).body
    
    # result will be a request id. time to store it with some information about why it was created
    # just so we can delete it later.    
    update_attribute(:facebook_ref_id, result.gsub("\"", "").to_i)
  end
  
  def close!
   
    result = HTTParty.delete("https://graph.facebook.com/#{self.facebook_ref_id}", :body => {:access_token => access_token}).body
    update_attribute(:open, false) if result.to_s == "true"
    
    #  TODO: somethign here with existing FB app requests
    # //Process and delete app requests
    #  $data = json_decode($requests);
    #  foreach($data->data as $item) {
    #   $id = $item->id;
    #   $delete_url = "https://graph.facebook.com/" .
    #   $id . "?" . $access_token;
    # 
    #   $delete_url = $delete_url . "&method=delete";
    #   $result = file_get_contents($delete_url);
    #   echo("Requests deleted? " . $result);
    #  }
    
  end 
  
end
