require 'test_helper'

class Affiliate::EmploymentsControllerTest < ActionController::TestCase

  context "when logged in as affiliate" do
    setup do 
      @user = Factory(:affiliate)
      @bar = Factory(:bar, :affiliate => @user)
      sign_in(@user)
    end
    
    # INDEX
    context "on GET to INDEX" do
      setup { get :index, :bar_id => @bar.id }
      
      should respond_with(:success)
      should render_template(:index)
      should assign_to(:bar)
      should assign_to(:employment)
      should assign_to(:employments)
    
      should "have employments from bar" do
        assert_equal @bar.employments, assigns(:employments)
      end
      
      should "have a new record" do
        assert assigns(:employment).new_record?
      end
    end
    
    context "on POST to CREATE" do
      setup do 
        @employee = Factory(:customer)
        @employment_size = @bar.employments.size
        post :create, :bar_id => @bar.id, :employment => {:user_id => "#{@employee.id}"}
      end
      
      should assign_to(:bar)
      
      should "increase employment count" do
        assert_equal 1, @bar.employments(true).size - @employment_size, @bar.employments(true).inspect
      end
      
      should respond_with(:redirect)
      should redirect_to("the staff page"){ affiliate_bar_employments_url(@bar) }
      should set_the_flash.to("Employee added. Get to work!") 
      
      should "have employees" do
        assert @bar.employees(true).present?, @bar.employments(true).inspect
        assert_equal @employee, @bar.employees(true).first
      end
    end
    
    context "on PUT to DESTROY" do
      setup do 
        @employment = Factory(:employment, :bar => @bar)
        @employment_size = @bar.employments.size
        put :destroy, :bar_id => @bar.id, :id => @employment.id
      end
      
      should assign_to(:bar)
      
      should "decrease employment count" do
        assert_equal -1, @bar.employments(true).size - @employment_size
      end
      
      should respond_with(:redirect)
      should redirect_to("the staff page"){ affiliate_bar_employments_url(@bar) }
      should set_the_flash.to("Your employee was fired!") 
    end
  
  end #logged in as affiliate

end
