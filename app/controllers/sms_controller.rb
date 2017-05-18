class SmsController < ApplicationController
  
  # Controller for sending vouchers via SMS
  # Here's an example of what we send tropo:
  # curl -d "action=create& /
  # token=d28ea31b107af243a89b42394c2aba462559f57b38c9770913498a444bd2f7171c608807963fccc8a98ba6e5 /
  # &msg=buy+another_round /
  # &numberToDial=4917623581384" 
  # http://api.tropo.com/1.0/sessions
  
  def create
    # Tropo POSTs to this url and expects a json response to instruct it on what action to take
    # For this method we tell it to send an sms
    # Tropo passes:
    # {"session" => {
    #   "id"=>"f9e1e0fde9ade9591a4a4c68261ba5ee", 
    #   "accountId"=>"66173", 
    #   "timestamp"=>2011-05-04 13:00:13 UTC, 
    #   "userType"=>"NONE", 
    #   "initialText"=>nil,
    #   "callId"=>nil, 
    #   "parameters"=>{
    #     "numberToDial"=>"4917623581384", 
    #     "format"=>"form", 
    #     "msg"=>"buy another round"
    #     "iou_id" => "534"
    #     ANY OTHER PARAMETERS WILL BE IN HERE
    #   }
    # }}
    
    if (params[:session].present? and params[:session].has_key?('parameters') and params[:session][:parameters].has_key?('iou_id')) 
      @iou = Iou.find(params[:session][:parameters]['iou_id'])
      @iou.sms_sent! if @iou.present?
    end
    
    # Create a new instance of the Tropo object
    @sms = Tropo::Generator.new
    
    # The number to send the SMS to
    if (params[:session].present? and params[:session].has_key?('parameters') and params[:session][:parameters].has_key?('numberToDial'))
      @to = "+#{params[:session][:parameters]['numberToDial']}"
    elsif (@iou.present? and @iou.recipient_phone.present?)
      @to = "+#{@iou.recipient_phone}"
    else
      @to = "error"
    end
  
    # The message to send   
    if (params[:session].present? and params[:session].has_key?('parameters') and params[:session][:parameters].has_key?('msg')) 
      @msg = params[:session][:parameters][:msg] 
    elsif @iou.present?
      @msg = @iou.sms_message
    else
      @msg = I18n.translate("sms.error_message")
    end
    
    # If there is no number to send the message to, send an error to the admin
    if @to == "error"
      Notifier.sms_error(params, @msg).deliver
      render :nothing => true
    else
      # for some reason Tropo doesn't like the @ variable when passed to the say object
      msg = @msg
      # This is all we need to construct the message
      @sms.message({:to => @to, :network => "SMS", :from => Rails.env.production? ? '16047570651' : Rails.env.staging? ? '13016837843' : '12048004142'}) do
        say :value => msg
      end
    
      # By rendering this we tell tropo what to send
      render :json => @sms
    end
  end
  
end
