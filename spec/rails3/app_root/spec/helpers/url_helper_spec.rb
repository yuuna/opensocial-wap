# -*- coding: utf-8 -*-
require 'spec_helper'

# コントローラをセットする.
def set_controller(c)
  controller = c
  helper.controller = c
  c.request = helper.request
  helper.stub!(:params).and_return({ :opensocial_app_id => '12345' })
end

describe OpensocialWap::Helpers::UrlHelper do
  fixtures :users

  describe "#url_for" do
    context "osw_options を指定していない場合" do
      it "従来の形式の URL を返すこと" do
        controller = NonOpensocialWapController.new
        helper.url_for(users(:alice)).should == "/users/1"
      end
    end
    
    context "osw_options を指定している場合" do
      it ":url_format が :plain であれば、指定した形式の URL を返すこと" do
        controller = OpensocialWapPlainController.new
        osw_options = controller.class.opensocial_wap_options
        helper.url_for(User.new, osw_options).should == "http://test.host/users"
      end

      it ":url_format が :query であれば、指定した形式の URL を返すこと" do
        controller = OpensocialWapQueryController.new
        osw_options = controller.class.opensocial_wap_options
        helper.url_for(User.new, osw_options).should == "?guid=ON&url=http%3A%2F%2Ftest.host%2Fusers"
      end

      it ":url_format が :full であれば、指定した形式の URL を返すこと" do
        controller = OpensocialWapFullController.new
        helper.stub!(:params).and_return({ :opensocial_app_id => '12345' })
        osw_options = controller.class.opensocial_wap_options
        helper.url_for(User.new, osw_options).should == "http://container.example.com/12345/?guid=ON&url=http%3A%2F%2Ftest.host%2Fusers"
      end
    end
  end

  describe "#link_to" do

    context NonOpensocialWapController do

      before do
        set_controller(NonOpensocialWapController.new)
      end

      it "リンクのURLが、通常の形式になること(パスを引数にした場合)" do
        link = helper.link_to("Alice", user_path(users(:alice)))
        link.should == %Q|<a href="/users/1">Alice</a>|
      end
    
      it "リンクのURLが、通常の形式になること(モデルを引数にした場合)" do
        link = helper.link_to("Alice", users(:alice))
        link.should == %Q|<a href="/users/1">Alice</a>|
      end

      it "リンクのURLが、通常の形式になること(Hashを引数にした場合)" do
        link = helper.link_to("Alice", :controller=>"users", :action=>"show", :id=>users(:alice))
        link.should == %Q|<a href="/users/1">Alice</a>|
      end

      it "外部URLの場合、そのままのURLが出力されること" do
        link = helper.link_to("Alice", "http://alice.example.com")
        link.should == %Q|<a href="http://alice.example.com">Alice</a>|
      end

      it "HTMLオプションが正しく追加されること" do
        link = helper.link_to("Alice", users(:alice), :class=>"user")
        link.should == %Q|<a href="/users/1" class="user">Alice</a>|
      end

      it "link_to メソッドのオプションで、URL形式を変更できること" do
        link_plain = helper.link_to("Alice", users(:alice), :opensocial_wap => {:url_format => :plain})
        link_plain.should == %Q|<a href="http://test.host/users/1">Alice</a>|

        link_query = helper.link_to("Alice", users(:alice), :opensocial_wap =>  {:url_format => :query})
        link_query.should == %Q|<a href="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|

        link_full = helper.link_to("Alice", users(:alice), :opensocial_wap =>  {:url_format => :full})
        link_full.should == %Q|<a href="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|
      end
    end

    context OpensocialWapPlainController do

      before do
        set_controller(OpensocialWapPlainController.new)
      end

      it "リンクのURLが、Opensocial WAP :plain形式になること(パスを引数にした場合)" do
        link = helper.link_to("Alice", user_path(users(:alice)))
        link.should == %Q|<a href="http://test.host/users/1">Alice</a>|
      end
    
      it "リンクのURLが、Opensocial WAP :plain形式になること(モデルを引数にした場合)" do
        link = helper.link_to("Alice", users(:alice))
        link.should == %Q|<a href="http://test.host/users/1">Alice</a>|
      end

      it "リンクのURLが、Opensocial WAP :plain形式になること(Hashを引数にした場合)" do
        link = helper.link_to("Alice", :controller=>"users", :action=>"show", :id=>users(:alice))
        link.should == %Q|<a href="http://test.host/users/1">Alice</a>|
      end

      it "外部URLの場合、リンクのURLが、Opensocial WAP の影響を受けないこと" do
        link = helper.link_to("Alice", "http://alice.example.com")
        link.should == %Q|<a href="http://alice.example.com">Alice</a>|
      end

      it "HTMLオプションが正しく追加されること" do
        link = helper.link_to("Alice", users(:alice), :class=>"user")
        link.should == %Q|<a href="http://test.host/users/1" class="user">Alice</a>|
      end

      it "link_to メソッドのオプションで、URL形式を変更できること" do
        link_query = helper.link_to("Alice", users(:alice), :opensocial_wap => {:url_format => :query})
        link_query.should == %Q|<a href="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|

        link_full = helper.link_to("Alice", users(:alice), :opensocial_wap => {:url_format => :full})
        link_full.should == %Q|<a href="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|
      end
    end
    
    context OpensocialWapQueryController do

      before do
        set_controller(OpensocialWapQueryController.new)
      end
      
      it "リンクのURLが、Opensocial WAP :query形式になること(パスを引数にした場合)" do
        link = helper.link_to("Alice", user_path(users(:alice)))
        link.should == %Q|<a href="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|
      end
    
      it "リンクのURLが、Opensocial WAP :query形式になること(モデルを引数にした場合)" do
        link = helper.link_to("Alice", users(:alice))
        link.should == %Q|<a href="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|
      end

      it "リンクのURLが、Opensocial WAP :query形式になること(Hashを引数にした場合)" do
        link = helper.link_to("Alice", :controller=>"users", :action=>"show", :id=>users(:alice))
        link.should == %Q|<a href="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|
      end

      it "外部URLの場合、リンクのURLが、Opensocial WAP の影響を受けないこと" do
        link = helper.link_to("Alice", "http://alice.example.com")
        link.should == %Q|<a href="http://alice.example.com">Alice</a>|
      end

      it "HTMLオプションが正しく追加されること" do
        link = helper.link_to("Alice", users(:alice), :class=>"user")
        link.should == %Q|<a href="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1" class="user">Alice</a>|
      end

      it "link_to メソッドのオプションで、URL形式を変更できること" do
        link_plain = helper.link_to("Alice", users(:alice), :opensocial_wap => {:url_format => :plain})
        link_plain.should == %Q|<a href="http://test.host/users/1">Alice</a>|

        link_full = helper.link_to("Alice", users(:alice), :opensocial_wap => {:url_format => :full})
        link_full.should == %Q|<a href="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|
      end
    end
    
    describe OpensocialWapFullController do

      before do
        set_controller(OpensocialWapFullController.new)
      end

      it "リンクのURLが、Opensocial WAP :full形式になること(パスを引数にした場合)" do
        link = helper.link_to("Alice", user_path(users(:alice)))
        link.should == %Q|<a href="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|
      end
    
      it "リンクのURLが、Opensocial WAP :full形式になること(モデルを引数にした場合)" do
        link = helper.link_to("Alice", users(:alice))
        link.should == %Q|<a href="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|
      end

      it "リンクのURLが、Opensocial WAP :full形式になること(Hashを引数にした場合)" do
        link = helper.link_to("Alice", :controller=>"users", :action=>"show", :id=>users(:alice))
        link.should == %Q|<a href="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|
      end

      it "外部URLの場合、リンクのURLが、Opensocial WAP の影響を受けないこと" do
        link = helper.link_to("Alice", "http://alice.example.com")
        link.should == %Q|<a href="http://alice.example.com">Alice</a>|
      end

      it "HTMLオプションが正しく追加されること" do
        link = helper.link_to("Alice", users(:alice), :class=>"user")
        link.should == %Q|<a href="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1" class="user">Alice</a>|
      end

      it "link_to メソッドのオプションで、URL形式を変更できること" do
        link_plain = helper.link_to("Alice", users(:alice), :opensocial_wap => {:url_format => :plain})
        link_plain.should == %Q|<a href="http://test.host/users/1">Alice</a>|

        link_query = helper.link_to("Alice", users(:alice), :opensocial_wap => {:url_format => :query})
        link_query.should == %Q|<a href="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1">Alice</a>|
      end
    end
  end

  describe "#button_to" do

    before do
      set_controller(NonOpensocialWapController.new)
    end

    context NonOpensocialWapController do
      it "ボタンのURLが、通常の形式になること(パスを引数にした場合)" do
        html = helper.button_to("Alice", user_path(users(:alice)))
        html.should include %Q|action="/users/1"|
      end
    
      it "ボタンのURLが、通常の形式になること(モデルを引数にした場合)" do
        html = helper.button_to("Alice", users(:alice))
        html.should include %Q|action="/users/1"|
      end

      it "ボタンのURLが、通常の形式になること(Hashを引数にした場合)" do
        html = helper.button_to("Alice", :controller=>"users", :action=>"show", :id=>users(:alice))
        html.should include %Q|action="/users/1"|
      end

      it "外部URLの場合、そのままのURLが出力されること" do
        html = helper.button_to("Alice", "http://alice.example.com")
        html.should include %Q|action="http://alice.example.com"|
      end

      it "xxxxx button_to メソッドのオプションで、URL形式を変更できること" do
        html_plain = helper.button_to("Alice", users(:alice), :opensocial_wap => {:url_format => :plain})
        html_plain.should include %Q|action="http://test.host/users/1"|

        html_query = helper.button_to("Alice", users(:alice), :opensocial_wap =>  {:url_format => :query})
        html_query.should include %Q|action="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|

        html_full = helper.button_to("Alice", users(:alice), :opensocial_wap =>  {:url_format => :full})
        html_full.should include %Q|action="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|
      end
    end

    context OpensocialWapPlainController do

      before do
        set_controller(OpensocialWapPlainController.new)
      end

      it "ボタンのURLが、Opensocial WAP :plain形式になること(パスを引数にした場合)" do
        html = helper.button_to("Alice", user_path(users(:alice)))
        html.should include %Q|action="http://test.host/users/1"|
      end
    
      it "ボタンのURLが、Opensocial WAP :plain形式になること(モデルを引数にした場合)" do
        html = helper.button_to("Alice", users(:alice))
        html.should include %Q|action="http://test.host/users/1"|
      end

      it "ボタンのURLが、Opensocial WAP :plain形式になること(Hashを引数にした場合)" do
        html = helper.button_to("Alice", :controller=>"users", :action=>"show", :id=>users(:alice))
        html.should include %Q|action="http://test.host/users/1"|
      end

      it "外部URLの場合、ボタンのURLが、Opensocial WAP の影響を受けないこと" do
        html = helper.button_to("Alice", "http://alice.example.com")
        html.should include %Q|action="http://alice.example.com"|
      end

      it "button_to メソッドのオプションで、URL形式を変更できること" do
        html_query = helper.button_to("Alice", users(:alice), :opensocial_wap => {:url_format => :query})
        html_query.should include %Q|action="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|

        html_full = helper.button_to("Alice", users(:alice), :opensocial_wap => {:url_format => :full})
        html_full.should include %Q|action="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|
      end
    end

    context OpensocialWapQueryController do

      before do
        set_controller(OpensocialWapQueryController.new)
      end

      it "ボタンのURLが、Opensocial WAP :query形式になること(パスを引数にした場合)" do
        html = helper.button_to("Alice", user_path(users(:alice)))
        html.should include %Q|action="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|
      end
    
      it "ボタンのURLが、Opensocial WAP :query形式になること(モデルを引数にした場合)" do
        html = helper.button_to("Alice", users(:alice))
        html.should include %Q|action="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|
      end

      it "ボタンのURLが、Opensocial WAP :query形式になること(Hashを引数にした場合)" do
        html = helper.button_to("Alice", :controller=>"users", :action=>"show", :id=>users(:alice))
        html.should include %Q|action="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|
      end

      it "外部URLの場合、ボタンのURLが、Opensocial WAP の影響を受けないこと" do
        html = helper.button_to("Alice", "http://alice.example.com")
        html.should include %Q|action="http://alice.example.com"|
      end

      it "button_to メソッドのオプションで、URL形式を変更できること" do
        html_plain = helper.button_to("Alice", users(:alice), :opensocial_wap => {:url_format => :plain})
        html_plain.should include %Q|action="http://test.host/users/1"|

        html_full = helper.button_to("Alice", users(:alice), :opensocial_wap => {:url_format => :full})
        html_full.should include %Q|action="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|
      end
    end

    context OpensocialWapFullController do

      before do
        set_controller(OpensocialWapFullController.new)
      end

      it "ボタンのURLが、Opensocial WAP :full形式になること(パスを引数にした場合)" do
        html = helper.button_to("Alice", user_path(users(:alice)))
        html.should include %Q|action="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|
      end
    
      it "ボタンのURLが、Opensocial WAP :full形式になること(モデルを引数にした場合)" do
        html = helper.button_to("Alice", users(:alice))
        html.should include %Q|action="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|
      end

      it "ボタンのURLが、Opensocial WAP :full形式になること(Hashを引数にした場合)" do
        html = helper.button_to("Alice", :controller=>"users", :action=>"show", :id=>users(:alice))
        html.should include %Q|action="http://container.example.com/12345/?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|
      end

      it "外部URLの場合、ボタンのURLが、Opensocial WAP の影響を受けないこと" do
        html = helper.button_to("Alice", "http://alice.example.com")
        html.should include %Q|action="http://alice.example.com"|
      end

      it "button_to メソッドのオプションで、URL形式を変更できること" do
        html_plain = helper.button_to("Alice", users(:alice), :opensocial_wap => {:url_format => :plain})
        html_plain.should include %Q|action="http://test.host/users/1"|

        html_query = helper.button_to("Alice", users(:alice), :opensocial_wap => {:url_format => :query})
        html_query.should include %Q|action="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2F1"|
      end
    end
  end

  describe "#link_to_unless_if" do
    context OpensocialWapQueryController do
      it "link_to_if についても、OpenSocial WAP形式のURLがセットされること" do
        set_controller(OpensocialWapQueryController.new)
        user = nil

        link = helper.link_to_if(user.nil?, "Register", { :controller => "users", :action => "new" })
        link.should == %Q|<a href="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2Fnew">Register</a>|
      end
    end
  end

  describe "#link_to_unless" do
    context OpensocialWapQueryController do
      it "link_to_unless についても、OpenSocial WAP形式のURLがセットされること" do
        set_controller(OpensocialWapQueryController.new)
        user = nil

        link = helper.link_to_unless(user, "Register", { :controller => "users", :action => "new" })
        link.should == %Q|<a href="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers%2Fnew">Register</a>|
      end
    end
  end

  describe "#link_to_unless_current" do
    context OpensocialWapQueryController do
      
      before do
        set_controller(OpensocialWapQueryController.new)
      end

      it "link_to_unless_current についても、OpenSocial WAP形式のURLがセットされること" do        
        link = helper.link_to_unless_current("Index", { :controller => "users", :action => "index" })
        link.should == %Q|<a href="?guid=ON&amp;url=http%3A%2F%2Ftest.host%2Fusers">Index</a>|
      end

      it "リンク先が現在のパスと同じであれば、link_to_unless_current の結果がリンクにならないこと" do
        # 比較対象のパスは、ローカル形式のパス.
        controller.request.path = '/users'

        helper.link_to_unless_current("Index", { :controller => "users", :action => "index" }).should == 'Index'
      end
    end
  end
end
