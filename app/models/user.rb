class User < ActiveRecord::Base

  #################
  # required for authlogic
  acts_as_authentic do |config|
    # using email field as login field
    login_field = :email
    # changing the validation of length of password field from 6 to 24 characters (default in authlogic it is 4 to 25)
    password_length_constraints = config.validates_length_of_password_field_options.reject { |k,v| [:minimum, :maximum].include?(k) }
    config.validates_length_of_password_field_options = password_length_constraints.merge :within => 6..24
  end

  # attribute accessible of User model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :facebookId

  ############
  # Relationships between the models
  # has-one belongs-to relationship with user and profile tables
  has_one :profile
  # has-many relationship between user and snaps tables
  has_many :snaps
  # has-one relationship between user and profile_snap tables
  has_one :profile_snap
  # has-many relationship between user and albums tables 
  has_many :albums
  # has-many relationship between user and friends tables
  has_many :friends
  # has-many relationship between user and demos tables
  has_many :demos

  # Constant for admin access email
  ADMIN_ACCESS = ["ajaykandwal27@gmail.com"]

  #######################
  # Default and Named Scopes for User model
  scope :full_name, lambda{|user_id| {:conditions => ["id =?", user_id] } }

  ################
  # Validations of User Model
  validates :first_name, :presence =>{:message => "First name can't be blank."}, :format => { :with => /\A[a-zA-Z0-9,.  -]+\z/, :message => "First name is not in valid format." }, :length => { :maximum => 25, :minimum => 2, :message  => "First name should be between 2 to 25 characters." }
  validates :last_name,  :presence =>{:message => "Last name can't be blank."}, :format => { :with => /\A[a-zA-Z0-9,.  -]+\z/, :message => "Last name is not in valid format." }, :length => { :maximum => 25, :minimum => 2, :message => "Last name should be between 2 to 25 characters." }

  # method for getting the full name of user with email address mainly used in Mails
  def email_address_with_name
    "#{self.first_name} <#{self.email}>"
  end

  # method for getting full name of user
  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

end
