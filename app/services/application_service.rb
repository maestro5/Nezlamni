class ApplicationService
  attr_reader :resource

  delegate :errors, to: :resource

  # def self.call(*args)
  #   new(*args).tap(&:perform)
  # end

  def perform
    ActiveRecord::Base.transaction do
      return true if executing

      errors[:service] << { transaction: [I18n.t('.errors.service.uknown')] } if success?
      raise ActiveRecord::Rollback
    end

    false
  end

  def success?
    errors.empty?
  end

  private

  def initialize(*_args)
  end

  def executing
    raise 'not implemented'
  end
end
