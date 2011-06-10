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
 end
