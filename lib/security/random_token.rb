class Security::RandomToken
  def self.same?(token, digest_token)
    BCrypt::Password.new(digest_token) == token
  end
  
  def initialize
    @token = SecureRandom.urlsafe_base64(16)
  end
  
  def to_s
    @token
  end
  
  def digest
    BCrypt::Password.create(@token)
  end
end