class Admin::CitiesController < Admin::BaseController
  # GET /admin/cities
  # GET /admin/cities.xml
  def index
    @admin_cities = City.order('country_id, name')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_cities }
    end
  end

  # GET /admin/cities/1
  # GET /admin/cities/1.xml
  def show
    @admin_city = City.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin_city }
    end
  end

  # GET /admin/cities/new
  # GET /admin/cities/new.xml
  def new
    @admin_city = City.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_city }
    end
  end

  # GET /admin/cities/1/edit
  def edit
    @admin_city = City.find(params[:id])
  end

  # POST /admin/cities
  # POST /admin/cities.xml
  def create
    @admin_city = City.new(params[:city])

    respond_to do |format|
      if @admin_city.save
        format.html { redirect_to(admin_city_path(@admin_city), :notice => 'City was successfully created.') }
        format.xml  { render :xml => @admin_city, :status => :created, :location => @admin_city }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin_city.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/cities/1
  # PUT /admin/cities/1.xml
  def update
    @admin_city = City.find(params[:id])

    respond_to do |format|
      if @admin_city.update_attributes(params[:city])
        format.html { redirect_to(admin_city_path(@admin_city), :notice => 'City was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @admin_city.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/cities/1
  # DELETE /admin/cities/1.xml
  def destroy
    @admin_city = City.find(params[:id])
    @admin_city.destroy

    respond_to do |format|
      format.html { redirect_to(admin_cities_url) }
      format.xml  { head :ok }
    end
  end
end
