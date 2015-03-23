class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  after_create :add_subscription_to_user
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable


  ## Database authenticatable
  field :first_name,              type: String, default: ""
  field :last_name,              type: String, default: ""
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  #for mailchimp
  field :euid, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## for Metrics
  field :sent_pos, type: Integer

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time



  def add_subscription_to_user(selected_plan = :trial)
    subscription = Subscription.new(user_id: id)
    subscription.save_without_payment(selected_plan, email, last_name)
    update_attribute(:subscription, subscription)
  end


  belongs_to :company
  has_one :subscription

end
