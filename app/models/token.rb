class Token < Struct.new(:id, :scope, :exp)
  class_attribute :scope, :ttl, instance_accessor: false

  # Builds a new token class with the specified attributes
  def self.derive(scope, ttl)
    Class.new(self).tap do |klass|
      klass.scope = scope
      klass.ttl = ttl
    end
  end

  # Returns a human readable string representation of the token class
  def self.inspect
    "Token (scope: #{scope.inspect}, ttl: #{ttl.inspect})"
  end

  # Returns a new token for a record
  def self.for(record)
    new(record.id, scope.to_s, ttl.seconds.from_now.to_i)
  end

  # Returns a token from a token string
  #
  # Raises JWT::DecodeError on failure
  def self.from_s(token)
    decode(token).tap do |t|
      raise JWT::DecodeError.new('Token out of scope') if !t.valid_scope?
    end
  end

  # Returns true if the token is in scope else false
  def valid_scope?
    scope.to_s == self.class.scope.to_s
  end

  # Encodes the token to a string
  def to_s
    JWT.encode(to_h, self.class.secret)
  end

  # Returns a human readable string representation of the token
  def inspect
    "#<Token id: #{id.inspect}, scope: #{scope.inspect}, exp: #{exp.inspect}>"
  end

  private

  # Decodes a token string
  #
  # Raises JWT::DecodeError on failure
  def self.decode(token)
    claims, _ = JWT.decode(token, secret)
    new(claims['id'], claims['scope'], claims['exp'])
  end

  # Returns the secret used for token signing
  def self.secret
    Rails.application.secrets.secret_key_base
  end
end
