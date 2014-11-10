class User
  include Elasticsearch::Persistence::Model
  include ActiveModel::SecurePassword
  has_secure_password(validations: false)

  index_name "users"

  # this is needed for validations only, but do NOT put :password here coz "has_secure_password" will fail:
  attr_accessor :password_confirmation

  # note: it's not typical for an index to have almost every attribute set as "not_analyzed",
  #       but in this case it's necessary for all of the validations to work properly:
  attribute :username, String, mapping: { index: "not_analyzed" }
  attribute :admin, Boolean, default: false, mapping: { type: "boolean", index: "not_analyzed" }
  attribute :email, String, mapping: { index: "not_analyzed" }
  attribute :password_digest, String, mapping: { index: "not_analyzed" }
  attribute :auth_token, String, mapping: { index: "not_analyzed" }
  attribute :password_reset_token, String, mapping: { index: "not_analyzed" }
  attribute :password_reset_sent_at, Date, mapping: { index: "not_analyzed" }

  validates :username, presence: true,
            # uniqueness: {case_sensitive: false},
            length: {minimum: 3}
  validate :username_uniqueness

  validates :email, presence: true,
            # uniqueness: {case_sensitive: false},
            length: {minimum: 3},
            # format: {with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
            format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}
  validate :email_uniqueness

  # note: "uniqueness:" and the following don't work using Elasticsearch::Persistence::Model:
  # validates :password, presence: true, length: {minimum: 6}, on: :create
  # validates :password, presence: true, length: {minimum: 6}, on: :update, :if => :password_digest_changed?
  # validates_confirmation_of :password, on: :update, :if => :password_digest_changed?

  validate :passwords_on_create
  validate :passwords_on_update

  ROLES = %w[admin user]

  def self.create_user_index
    client = User.gateway.client
    client.indices.delete(index: User.index_name) rescue nil
    client.indices.create(index: User.index_name, body: {mappings: User.mappings.to_hash})
  end

  def username_uniqueness
    return unless self.id.blank? # id is nil on creation of a new doc
    user = User.find_by_username(self.username)
    return if user.blank?
    self.errors["Name"] << "already exists, but must be unique"
  end

  def email_uniqueness
    return unless self.id.blank? # id is nil on creation of a new doc
    user = User.find_by_email(self.email)
    return if user.blank?
    self.errors["Email"] << "already exists, but must be unique"
  end

  def passwords_on_create
    return unless self.id.blank? # id is nil on creation of a new doc
    self.errors["Password"] << "is required" and return if self.password.blank?
    self.errors["Password Confirmation"] << "is required" and return if self.password_confirmation.blank?
    self.errors["Passwords"] << "entered must be the same" unless self.password_confirmation == self.password
    self.errors["Passwords"] << "must be a minimum of 6 characters" unless self.password_confirmation.size >= 6 && self.password.size >= 6
  end

  def passwords_on_update
    return if self.id.blank? # id is not nil on update of an existing doc
    if self.password.present? || self.password_confirmation.present?
      self.errors["Passwords"] << "both are required, if either was entered" and return if self.password_confirmation.blank? || self.password.blank?
      self.errors["Passwords"] << "entered must be the same" and return unless self.password_confirmation == self.password
      self.errors["Passwords"] << "must be a minimum of 6 characters" unless self.password_confirmation.size >= 6 && self.password.size >= 6
    end
  end

  def self.find_by_username(name)
    users = User.search(query:{match:{username: name}})
    return nil if users.blank?
    return nil if users.count > 1
    return users.first
    rescue => ex
      return nil
  end

  def self.find_by_auth_token!(token)
    users = User.search(query:{match:{auth_token: token}})
    return nil if users.blank?
    return nil if users.count > 1
    return users.first
    rescue => ex
      return nil
  end

  def self.find_by_email(email)
    emails = User.search(query:{match:{email: email}})
    return nil if emails.blank?
    return nil if emails.count > 1
    return emails.first
    rescue => ex
      return nil
  end

  def is_admin?
    self.admin
  end

  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while User.exists?(auth_token: token)
    token
  end

  def send_password_reset
    self.password_reset_token = generate_token
    self.password_reset_sent_at = Time.zone.now.utc
    save!
    UserMailer.password_reset(self.id).deliver
  end
end
