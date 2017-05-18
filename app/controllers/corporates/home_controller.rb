class Corporates::HomeController < ApplicationController
  before_filter :authenticate_corporate!, :only => [:buddy_groups]
  layout :choose_layout

  def buddy_groups
    @corporate = []
    @corporate = current_corporate
    @corporate.buddy_groups.build  if current_corporate.present?
  end

  def create_groups
    @corporate = Corporate.find(params[:id])
    unless @corporate.update_attributes(params[:corporate])
      render "buddy_groups"
    else
      flash[:notice] = "Buddy Groups have been sucessfully created."
      redirect_to corporates_buddy_groups_path
    end
  end

  def create_group_email
    buddy_group = BuddyGroup.find(params["group_id"])
    unless buddy_group.blank?
      buddy_email = buddy_group.buddy_emails.create(:email => params["email"])
      if buddy_email.save
        render :json => { :email=> buddy_email.email,:id=> buddy_email.id }
      else
        render :json => buddy_email.errors.full_messages.first#, :status => 422
      end
    end
  end

  def buddy_emails_destroy
    buddy_email = BuddyEmail.find(params["id"])
    if !buddy_email.blank? && buddy_email.destroy
      render :text=> true
    else
      render :text=> true
    end

  end

  private
  def choose_layout
    return "corporate_program" if ["buddy_groups", "create_groups"].include?(action_name)
  end
end
