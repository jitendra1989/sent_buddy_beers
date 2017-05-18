# -*- coding: utf-8 -*-
require 'test_helper'

class PageTest < ActiveSupport::TestCase

  should have_and_belong_to_many(:sites)
  should validate_presence_of(:title)
  should validate_presence_of(:body)
  should validate_numericality_of(:position)
  
  context "a page" do
    
    setup { @page = Factory.build(:page, :title => "Title", :body => "Body") }
    
    # testing multi-language puret and friendly id
    context "with an english translation" do
      
      setup do
        I18n.with_locale(:en) do
          @page.save
        end
      end
      
      should "have a translation" do
        assert_equal 1, @page.translations(true).size
      end
      
      should "have a slug in english" do
        assert @page.slug == "title"
      end   
      
      context "and a german translation" do
             
        setup do
          I18n.with_locale(:de) do
            @page.title = "Übertitel"
            @page.body = "Korper"
            @page.save!
          end
        end
        
        should "have 2 translations" do
          assert_equal 2, @page.translations(true).size, @page.translations(true).inspect
        end
        
        should "have a german slug" do
          I18n.with_locale(:de) do
            assert @page.slug == "uebertitel"
          end
        end
          
      end
    end
    
    # testing acts_as_tree
    context "with a subpage" do
      
      setup do
        @page.save
        @subpage = Factory(:page, :parent_id => @page.id, :title => "Subtitle", :body => "body")
      end
    
      should "have children" do
        assert @page.children.present?
      end
      
      should "have be a parent" do
        assert Page.roots.include?(@page)
      end
      
      should "be the parent of the subpage" do
        assert @subpage.parent == @page
      end
    
    end
    
  end

end
