require 'spec_helper'

describe User do

  before(:each) do
    @attr = { :name => "Example User", :email => "user@example.com", 
              :password => "foobar", :password_confirmation => "foobar" }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    invalidUser = User.new(@attr.merge(:name => ""))
    invalidUser.should_not be_valid
  end

    it "should require an email" do
    invalidUser = User.new(@attr.merge(:email => ""))
    invalidUser.should_not be_valid
  end

    it "should not have an excessively long names" do
    lengthy_name = "b"*51
    invalUser = User.new(@attr.merge(:name => lengthy_name))
    invalUser.should_not be_valid
  end 
    
    it "should accept valid email addresses" do
      addresses = %w[foo@bar.com the_user@gb.bg.net ha.rof@lol.jp]
      addresses.each do |address|
        valUser = User.new(@attr.merge(:email=> address))
        valUser.should be_valid
      end
    end 
    
    it "should not accept invalid email addresses" do
      addresses = %w[foo@bar,com user_at_foo.org example@user.foo. ]
      addresses.each do |address|
        invalUser = User.new(@attr.merge(:email => address))
        invalUser.should_not be_valid
      end
    end
    
    it "should reject duplicate email addresses" do
      User.create!(@attr)
      dupUser = User.new(@attr)
      dupUser.should_not be_valid
    end

   it "should reject email identicals up to case" do
     upcased_email = @attr[:email].upcase
     User.create!(@attr.merge(:email => upcased_email))
     dupUser = User.new(@attr)
     dupUser.should_not be_valid
   end
   
   describe "password validations" do
  
     it "should require a password" do
       User.new(@attr.merge(:password => "", :password_confirmation => "")).
         should_not be_valid
     end
  
     it "should require a matching password confirmation" do
       User.new(@attr.merge(:password_confirmation => "invalid")).
         should_not be_valid
     end

     it "should reject short passwords" do
       short = "a"*5
       hash = @attr.merge(:password => short, :password_confirmation => short)
       User.new(hash).should_not be_valid
     end

     it "should reject long passwords" do
       long = "a"*41
       hash = @attr.merge(:password => long, :password_confirmation => long)
       User.new(hash).should_not be_valid
     end
   end

  describe "password encryption" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
 
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do
    
     it "should be true if the passwords match" do
       @user.has_password?(@attr[:password]).should be_true
     end

      it "should be false if the passwords don't match" do
        @user.has_password?("loller").should be_false
      end
     end
    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrongPasswordUser = User.authenticate(@attr[:email], "wrongpass")
        wrongPasswordUser.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistentUser = User.authenticate("Rofl@net.com", @attr[:password])
        nonexistentUser.should be_nil
      end

      it "should return the user on email/password match" do
        rightUser = User.authenticate(@attr[:email], @attr[:password])
        rightUser.should == @user
      end
    end
   end

  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "micropost association" do
    
    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "should destory associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include the user's microposts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end

      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost,
                      :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.include?(mp3).should be_false
      end

      it "should include the microposts of followed users" do
        followed = Factory(:user, :email => Factory.next(:email))
        mp3 = Factory(:micropost, :user => followed)
        @user.follow!(followed)
        @user.feed.should include(mp3)
      end

    end
  end

  describe "relationships" do
  
    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end
 
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end

    it "should have a following method" do
      @user.should respond_to(:following)
    end

    it "should have a following? method" do
      @user.should respond_to(:following?)
    end

    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end

    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end
    
    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end

    it "should have an unfollow! method" do
      @followed.should respond_to(:unfollow!)
    end

    it "should unfollow a user" do
      @user.follow!(@followed) 
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end

    it "should have a followers method" do
      @user.should respond_to(:followers)
    end

    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
end
