class AdminUser < ActiveRecord::Base
  extend Filterable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable, :timeout_in => 365.days

  has_many :group_classes
  has_many :instructor_students
  has_many :award_tests

  [:instructor?, :admin?, :coordinator?, :accountant?].each{ |meth| define_method(meth){ false } }

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.match_password(password, user.encrypted_password)
      user
    else
      nil
    end
  end

  def match_password(password, salt)
    encrypted_password == BCrypt::Engine.hash_secret(password, salt)
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = AdminUser.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    # unless user
    #     user = User.create(
    #        email: data["email"],
    #        password: Devise.friendly_token[0,20]
    #     )
    # end
    user
  end


end
