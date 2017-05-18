require 'twilio-ruby'
class TwilioClient
  def send_message(receiver_number, sms_text, twilio_phone_number=nil)
    begin
      twilio_phone_number = APP_CONFIG['twilio_phone_number'] if twilio_phone_number.blank?
      client.account.sms.messages.create(
        :from => twilio_phone_number,
        :to => receiver_number,
        :body => sms_text
      )
      
    rescue Twilio::REST::RequestError => e
      Rails.logger.info "Twilio error ===== #{e.message} ====occurs on====#{Time.now}"
    end
  end

  private

  def client
    @_twilio_client ||= Twilio::REST::Client.new APP_CONFIG['twilio_sid'], APP_CONFIG['twilio_token']
  end
end 
