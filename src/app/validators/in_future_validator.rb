class InFutureValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, 'cannot be in the past') unless
      value.nil? || value >= Time.zone.today
  end
end
