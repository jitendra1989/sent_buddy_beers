require 'test_helper'

class Affiliate::PhotosControllerTest < ActionController::TestCase
  fixtures :users

  # affiliate/photos/new
  context "GET to :new" do
    setup { @bar = Factory(:bar, :affiliate_id => users(:affiliate).id) }

    context "while logged in as affiliate" do
      setup do
        sign_in :affiliate
        get :new, :bar_id => @bar.id
      end

      should assign_to(:bar)
      should assign_to(:gallery)
      should assign_to(:current_user)
      should assign_to(:photo)
      should respond_with(:success)
      should render_template(:new)
      should_not set_the_flash

      should "have a new instance of photo" do
        assert assigns(:photo).new_record?
        assert_equal assigns(:photo).gallery, assigns(:gallery)
      end
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :new, :bar_id => @bar.id
      end

      should_not assign_to(:bar)
      should_not assign_to(:gallery)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  # affiliate/photos/create

    context "POST to :create" do
      setup do
        @bar = Factory(:bar, :affiliate_id => users(:affiliate).id)
        @photo_count = @bar.gallery(true).photos.length
      end

      context "while logged in as affiliate" do
        setup do
          sign_in :affiliate
          post :create, :bar_id => @bar.id, :photo => Factory.attributes_for(:photo, :title => "title", :description => "this is a description of the photo")
        end

        should assign_to(:bar)
        should assign_to(:gallery)
        should assign_to(:current_user)
        should assign_to(:photo)

        should respond_with(:redirect)
        should redirect_to("the bars gallery page page"){ gallery_affiliate_bar_path(@bar) }
        should set_the_flash.to("Photo was successfully added")

        should "raise the photo count by one" do
          assert_equal 1, @bar.gallery(true).photos.length - @photo_count
        end
      end

      context "while logged in as customer" do
        setup do
          sign_in :customer
          post :create, :bar_id => @bar.id, :photo => Factory.attributes_for(:photo, :title => "title", :description => "this is a description of the photo")
        end

        should_not assign_to(:bar)
        should_not assign_to(:gallery)
        should_not assign_to(:photo)
        should assign_to(:current_user)
        should respond_with(:redirect)
        should redirect_to("the home page"){ root_url }
        should set_the_flash.to("You do not have the correct privileges to access this page")

        should "not raise the photo count by one" do
          assert_equal @bar.gallery(true).photos.length, @photo_count
        end
      end
    end

  # affiliate/photos/edit

  context "GET to :edit" do
    setup do
      @bar = Factory(:bar, :affiliate_id => users(:affiliate).id)
      @photo = Factory(:photo, :title => "title", :description => "this is a description of the photo", :gallery_id => @bar.gallery(true).id)
    end

    context "while logged in as affiliate" do
      setup do
        sign_in :affiliate
        get :edit, :bar_id => @bar.id, :id => @photo.id
      end

      should assign_to(:bar)
      should assign_to(:gallery)
      should assign_to(:current_user)
      should assign_to(:photo)

      should respond_with(:success)
      should render_template(:edit)
      should_not set_the_flash

      should "not have a new photo record" do
        assert !assigns(:photo).new_record?
      end
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        get :edit, :bar_id => @bar.id, :id => @photo.id
      end

      should_not assign_to(:bar)
      should_not assign_to(:gallery)
      should_not assign_to(:photo)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  #affiliate/photos/update

  context "POST to :update" do
    setup do
      @bar = Factory(:bar, :affiliate_id => users(:affiliate).id)
      @photo = Factory(:photo, :title => "title", :description => "this is a description of the photo", :gallery_id => @bar.gallery(true).id)
    end

    context "while logged in as affiliate" do
      setup do
        sign_in :affiliate
        post :update, :bar_id => @bar.id, :id => @photo.id, :photo => {:title => "New Title"}
      end

      should assign_to(:bar)
      should assign_to(:gallery)
      should assign_to(:current_user)
      should assign_to(:photo)

      should respond_with(:redirect)
      should redirect_to("the bars gallery page"){ gallery_affiliate_bar_path(@bar) }
      should set_the_flash.to("Photo updated successfully")
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        post :update, :bar_id => @bar.id, :id => @photo.id, :photo => {:title => "New Title"}
      end

      should_not assign_to(:bar)
      should_not assign_to(:gallery)
      should_not assign_to(:photo)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")
    end
  end

  #affiliate/photos/destroy

  context "PUT to :destroy" do
    setup do
      @bar = Factory(:bar, :affiliate_id => users(:affiliate).id)
      @photo = Factory(:photo, :title => "title", :description => "this is a description of the photo", :gallery_id => @bar.gallery(true).id)
      @photo_count = @bar.gallery(true).photos.length
    end

    context "while logged in as affiliate" do
      setup do
        sign_in :affiliate
        put :destroy, :bar_id => @bar.id, :id => @photo.id
      end

      should assign_to(:bar)
      should assign_to(:gallery)
      should assign_to(:current_user)
      should assign_to(:photo)

      should respond_with(:redirect)
      should redirect_to("the bars gallery page"){ gallery_affiliate_bar_path(@bar) }
      should set_the_flash.to("Photo deleted!")

      should "lower the photo count by one" do
        assert_equal -1, assigns(:bar).gallery.photos.length - @photo_count
      end
    end

    context "while logged in as customer" do
      setup do
        sign_in :customer
        put :destroy, :bar_id => @bar.id, :id => @photo.id
      end

      should_not assign_to(:bar)
      should_not assign_to(:gallery)
      should_not assign_to(:photo)
      should assign_to(:current_user)
      should respond_with(:redirect)
      should redirect_to("the home page"){ root_url }
      should set_the_flash.to("You do not have the correct privileges to access this page")

      should "retaint he same photo count" do
        assert_equal 0, @bar.gallery(true).photos.length - @photo_count
      end
    end
  end

end
