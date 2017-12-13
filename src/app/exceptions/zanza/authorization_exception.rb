module Zanza
  class AuthorizationException < StandardError; end

  class ForbiddenException < StandardError; end

  class CallbackException < StandardError; end
end
