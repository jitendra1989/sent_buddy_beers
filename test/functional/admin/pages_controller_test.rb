require 'test_helper'

class Admin::PagesControllerTest < ActionController::TestCase
  fixtures :users
  
  setup do
    sign_in :admin
    @page = Factory(:page, :title => "Title", :body => "Body", :site_ids => [Thread.current[:current_site].id])
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create page" do
    assert_difference('Page.count') do
      post :create, :page => {:title => "Title", :body => "Body", :site_ids => [Thread.current[:current_site].id]}
    end

    assert_redirected_to admin_page_path(assigns(:page).slug)
  end

  test "should show page" do
    get :show, :id => @page.slug
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @page.id
    assert_response :success
  end

  test "should update page" do
    put :update, :id => @page.id, :page => {:title => "Title", :body => "Body", :site_ids => [Thread.current[:current_site].id]}
    assert_redirected_to admin_page_path(assigns(:page).slug)
  end

  test "should destroy page" do
    assert_difference('Page.count', -1) do
      delete :destroy, :id => @page.id
    end

    assert_redirected_to admin_pages_path
  end
end
