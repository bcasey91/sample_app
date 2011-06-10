require 'spec_helper'

describe UsersController do
  render_views

  describe "Get 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find right user" do
      get :show, :id => @user #here you have to use @user or @user.id, since 
                              #users are not going to be indexed/ found with
                              #email, name, etc.
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get :show, :id=> @user 
      response.should have_selector("title", :content => @user.name)
    end
 
    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
  end
#Following for demonstration/ illustration of what's happening- the assigns is
# responding to the get- so it's grabbing the user instance when the User.find 
# is called in the show action with the :id => x is used. The get is going into # the show action and making @user equal to x(due to stuff in show action), and
# the assigns goes and grabs the instance variable @user from the show action, 
# based on this assignment of @user from get. Whereas @user everywhere in here 
# is the @user created with the factory.   
#    it "should find the right user" do
#      x = User.create(:name => "Goffy", :email=>"lol@gogo.com", 
#                   :password=>"ffobra", :password_confirmation=> "ffobra")
#      get :show, :id => x
#      assigns(:user).should == x
#    end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

     it "should have the right title" do
       get 'new'
       response.should have_selector("title", :content => "Sign up")
     end
   end
end
