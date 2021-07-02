
class EventedRecord < ActiveRecord::Base
  self.abstract_class = true

  def save(**options, &block)
    self.uuid = SecureRandom.uuid unless uuid.present?
    create_event(__method__)

    super if allow_ar_mutations?
  end

  def save!(**options, &block)
    self.uuid = SecureRandom.uuid unless uuid.present?
    create_event(__method__)

    super if allow_ar_mutations?
  end

  def update_attribute(name, value)
    create_event(__method__, { name: value })

    super if allow_ar_mutations?
  end

  def update_column(name, value)
    create_event(__method__, { name: value })

    super if allow_ar_mutations?
  end

  def update_columns(attributes)
    create_event(__method__, attributes)

    super if allow_ar_mutations?
  end

  def delete
    create_event(__method__)

    super if allow_ar_mutations?
  end

  def destroy
    create_event(__method__)

    super if allow_ar_mutations?
  end

  private

  def create_event(method, attributes = nil)
    if changes.present?
      new_values = changes.map do |k,v|
        [k.to_s, v.last]
      end.to_h
    elsif attributes.present?
      new_values = attributes
    else
      new_values = { deleted_at: DateTime.new.iso8601 }
    end

    event = {
      model_name: self.class.name,
      uuid: uuid,
      method: method,
      new_values: new_values,
    }

    # eventually, this could be a call to write to some event stream
    Rails.logger.info "#{event}"
  end

  def allow_ar_mutations?
    ENV["ALLOW_AR_MUTATIONS"] || true
  end
end
