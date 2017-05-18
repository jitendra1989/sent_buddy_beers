class EmailInvitationsController < ApplicationController
  # GET /email_invitations
  # GET /email_invitations.xml
  # def index
  #     @email_invitations = EmailInvitation.all
  # 
  #     respond_to do |format|
  #       format.html # index.html.erb
  #       format.xml  { render :xml => @email_invitations }
  #     end
  #   end

  # GET /email_invitations/1
  # GET /email_invitations/1.xml
  # def show
  #     @email_invitation = EmailInvitation.find(params[:id])
  # 
  #     respond_to do |format|
  #       format.html # show.html.erb
  #       format.xml  { render :xml => @email_invitation }
  #     end
  #   end

  # GET /email_invitations/new
  # GET /email_invitations/new.xml
  # def new
  #     @email_invitation = EmailInvitation.new
  # 
  #     respond_to do |format|
  #       format.html # new.html.erb
  #       format.xml  { render :xml => @email_invitation }
  #     end
  #   end

  # GET /email_invitations/1/edit
  # def edit
  #     @email_invitation = EmailInvitation.find(params[:id])
  #   end

  # POST /email_invitations
  # POST /email_invitations.xml
  def create
    @email_invitation = EmailInvitation.new(params[:email_invitation])
    @email_invitation.user = current_user if current_user

    respond_to do |format|
      if @email_invitation.save
        format.html { redirect_to(@email_invitation, :notice => 'Email invitation was successfully created.') }
        format.xml  { render :xml => @email_invitation, :status => :created, :location => @email_invitation }
        format.json { render :json => @email_invitation, :status => :created }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @email_invitation.errors, :status => :unprocessable_entity }
        format.json  { render :json => @email_invitation.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /email_invitations/1
  # PUT /email_invitations/1.xml
  # def update
  #     @email_invitation = EmailInvitation.find(params[:id])
  # 
  #     respond_to do |format|
  #       if @email_invitation.update_attributes(params[:email_invitation])
  #         format.html { redirect_to(@email_invitation, :notice => 'Email invitation was successfully updated.') }
  #         format.xml  { head :ok }
  #       else
  #         format.html { render :action => "edit" }
  #         format.xml  { render :xml => @email_invitation.errors, :status => :unprocessable_entity }
  #       end
  #     end
  #   end

  # DELETE /email_invitations/1
  # DELETE /email_invitations/1.xml
  # def destroy
  #     @email_invitation = EmailInvitation.find(params[:id])
  #     @email_invitation.destroy
  # 
  #     respond_to do |format|
  #       format.html { redirect_to(email_invitations_url) }
  #       format.xml  { head :ok }
  #     end
  #   end
end
