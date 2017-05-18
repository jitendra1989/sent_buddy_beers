class WidgetsController < ApplicationController
  
  layout false
  
  # <script src="http://buddybeers.com/en/bars/seewolf-bierstube-restaurant-luebeck-germany/widgets.js" type="text/javascript"></script>
  # <div id="buddy-beers-bar-widget-container"></div>
  
  def index
    @bar = Bar.find(params[:bar_id], :include => :prices)
    respond_to do |format|
      format.html { redirect_to(bar_url(@bar)) }
      format.js
      format.json do
        # Store HTML in a variable rather than returning in to the browser
        html = render_to_string 
        # Build a JSON object containing our HTML
        json = {"html" => html}.to_json
        # Get the name of the JSONP callback created by jQuery
        callback = params[:callback]
        # Wrap the JSON object with a call to the JSONP callback
        jsonp = callback + "(" + json + ")"
        # Send result to the browser
        render :text => jsonp,  :content_type => "text/javascript"
      end
    end
  end

end
