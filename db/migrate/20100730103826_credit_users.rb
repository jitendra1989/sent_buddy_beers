class CreditUsers < ActiveRecord::Migration
  def self.up
    @client = CurrencyClient.get_client
    
    @users_who_sent_a_beer = Iou.paid.collect{ |i| i.sender }.uniq
    @users_who_sent_a_beer.each do |user|
      transaction do
        @response = @client.credit_user(user.id, 50000, "BUCKS_LAUNCH_CREDIT_FOR_#{user.id}", "new_user_credit", "Bonus for sending a beer in our beta phase")
        # returns: {:code=>"200", :body=>"{ \"socialgold_transaction_id\" : \"b32424cd2ce51a47d2603e0267efecb7\" , \"socialgold_transaction_status\" : \"SUCCESS\" , \"user_balance\" : \"73000\" }"}
        @credit_event = CreditEvent.new(:socialgold_transaction_id => JSON.parse(@response[:body])["socialgold_transaction_id"],
                                        :socialgold_transaction_status => JSON.parse(@response[:body])["socialgold_transaction_status"],
                                        :user_balance => JSON.parse(@response[:body])["user_balance"],
                                        :user_id => user.id,
                                        :premium_currency_amount => 50000, 
                                        :amount => 50000,
                                        :event_type => "CREDIT",
                                        :external_ref_id => "BUCKS_LAUNCH_CREDIT_FOR_#{user.id}",
                                        :name => "Sent a beer")
        @credit_event.save
        @credits = @client.get_balance_for_display(user.id)
        user.update_attribute(:credits, @credits)
      end
    end
    
    @existing_users = User.all
    @existing_users = @existing_users - @users_who_sent_a_beer
    
    @existing_users.each do |user|
      transaction do
        @response = @client.credit_user(user.id, 35000, "BUCKS_LAUNCH_CREDIT_FOR_#{user.id}", "new_user_credit", "Bonus for sending a beer in our beta phase")
        # returns: {:code=>"200", :body=>"{ \"socialgold_transaction_id\" : \"b32424cd2ce51a47d2603e0267efecb7\" , \"socialgold_transaction_status\" : \"SUCCESS\" , \"user_balance\" : \"73000\" }"}
        @credit_event = CreditEvent.new(:socialgold_transaction_id => JSON.parse(@response[:body])["socialgold_transaction_id"],
                                        :socialgold_transaction_status => JSON.parse(@response[:body])["socialgold_transaction_status"],
                                        :user_balance => JSON.parse(@response[:body])["user_balance"],
                                        :user_id => user.id,
                                        :premium_currency_amount => 35000, 
                                        :amount => 35000,
                                        :event_type => "CREDIT",
                                        :external_ref_id => "BUCKS_LAUNCH_CREDIT_FOR_#{user.id}",
                                        :name => "Existing user")
        @credit_event.save
        @credits = @client.get_balance_for_display(user.id)
        user.update_attribute(:credits, @credits)
      end
    end
  end

  def self.down
    @client = CurrencyClient.get_client
    
    @users_who_sent_a_beer = CreditEvent.find_all_by_event_type_and_name("CREDIT", "Sent a beer").collect{ |i| i.user }.uniq
    @users_who_sent_a_beer.each do |user|
      transaction do
        #debit_user(user_id, amount, description, external_ref_id, format='json') 
        @response = @client.debit_user(user.id, 50000, "Rolling back credit migration", "MIGRATION_ROLLBACK_FOR_#{user.id}")
        # returns: {:code=>"200", :body=>"{ \"socialgold_transaction_id\" : \"b32424cd2ce51a47d2603e0267efecb7\" , \"socialgold_transaction_status\" : \"SUCCESS\" , \"user_balance\" : \"73000\" }"}
        @credit_event = CreditEvent.new(:socialgold_transaction_id => JSON.parse(@response[:body])["socialgold_transaction_id"],
                                        :socialgold_transaction_status => JSON.parse(@response[:body])["socialgold_transaction_status"],
                                        :user_balance => JSON.parse(@response[:body])["user_balance"],
                                        :user_id => user.id,
                                        :premium_currency_amount => 50000, 
                                        :amount => 50000,
                                        :event_type => "DEBIT",
                                        :external_ref_id => "MIGRATION_ROLLBACK_FOR_#{user.id}",
                                        :name => "Sent a beer")
        @credit_event.save
        @credits = @client.get_balance_for_display(user.id)
        user.update_attribute(:credits, @credits)
      end
    end
    
    @existing_users = CreditEvent.find_all_by_event_type_and_name("CREDIT", "Existing user").collect{ |i| i.user }.uniq
    
    @existing_users.each do |user|
      transaction do
        @response = @client.debit_user(user.id, 35000, "Rolling back credit migration", "MIGRATION_ROLLBACK_FOR_#{user.id}")
        # returns: {:code=>"200", :body=>"{ \"socialgold_transaction_id\" : \"b32424cd2ce51a47d2603e0267efecb7\" , \"socialgold_transaction_status\" : \"SUCCESS\" , \"user_balance\" : \"73000\" }"}
        @credit_event = CreditEvent.new(:socialgold_transaction_id => JSON.parse(@response[:body])["socialgold_transaction_id"],
                                        :socialgold_transaction_status => JSON.parse(@response[:body])["socialgold_transaction_status"],
                                        :user_balance => JSON.parse(@response[:body])["user_balance"],
                                        :user_id => user.id,
                                        :premium_currency_amount => 35000, 
                                        :amount => 35000,
                                        :event_type => "DEBIT",
                                        :external_ref_id => "MIGRATION_ROLLBACK_FOR_#{user.id}",
                                        :name => "Existing user")
        @credit_event.save
        @credits = @client.get_balance_for_display(user.id)
        user.update_attribute(:credits, @credits)
      end
    end
  end
end
