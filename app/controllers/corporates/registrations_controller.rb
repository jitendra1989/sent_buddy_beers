class Corporates::RegistrationsController < Devise::RegistrationsController
  before_filter :require_corporate, :except => [:new, :create, :confirm, :startups_business]
  layout :choose_layout
  
  def edit
  end
  
  # PUT /resource
  def update
    params[:corporate].delete(:password) if params[:corporate][:password].blank? 
    if resource.update_attributes(params[resource_name])
      set_flash_message :notice, :updated
      sign_in resource_name, resource, :bypass => true
      redirect_to after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      render_with_scope :edit
    end
  end
  
  def delete_pic
    corporate = Corporate.find(params[:corporate_id])
    unless corporate.blank?
      corporate_pic = corporate.delete_pic?
      if corporate_pic
        flash[:notice] = "Corporate picture has been deleted successfully"
      else
        flash[:notice] = "Some things wrong !!"
      end
    end
    redirect_to edit_corporate_registration_url(corporate)
  end
  
  def confirm
    @corporate = Corporate.new(params[:corporate])
  end
  
  def startups_business
    render :layout => 'company_application'    
  end
  
  protected

  def after_inactive_sign_up_path_for(resource)
    business_perks_url
  end
  
  def after_sign_up_path_for(resource)
    edit_corporate_registration_url
  end
  
  def after_update_path_for(resource)
    edit_corporate_registration_url
  end
  
  private
  def choose_layout
    return "corporate_sign_up_in" if ["new", "create", "delete_pic"].include?(action_name)
    return "corporate_program" if ["edit", "update", "confirm"].include?(action_name)
  end
  
end
