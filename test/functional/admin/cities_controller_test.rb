require 'test_helper'

class Admin::CitiesControllerTest < ActionController::TestCase
  fixtures :users
  
  setup do
    sign_in :admin
    @admin_city = Factory(:city, :country => Factory(:country))
    puts City.order('country_id, name').all.collect{ |c| [c.name, c.country] }.inspect
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_cities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_city" do
    assert_difference('City.count') do
      post :create, :city => {:name => "New City", :country => Factory(:country)}
    end
  
    assert_redirected_to admin_city_path(assigns(:admin_city))
  end

  test "should show admin_city" do
    get :show, :id => @admin_city.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @admin_city.id
    assert_response :success
  end

  test "should update admin_city" do
    put :update, :id => @admin_city.id, :city => Factory.attributes_for(:city)
    assert_redirected_to admin_city_path(assigns(:admin_city))
  end

  test "should destroy admin_city" do
    assert_difference('City.count', -1) do
      delete :destroy, :id => @admin_city.id
    end

    assert_redirected_to admin_cities_path
  end
end
