module Zanza
  class PaymentException < StandardError; end

  class NoPaymentDetailsException < StandardError; end

  class FailedPaymentException < StandardError; end

  class UnSuccessfulPaymentError < StandardError; end

  class PaymentPreConditionsNotMet < StandardError; end
end
