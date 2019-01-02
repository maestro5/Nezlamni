class AccountForm
  attr_reader :params

  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :name, String
  attribute :birthday_on, Date
  attribute :goal, String
  attribute :budget, String
  attribute :deadline_on, Date
  attribute :phone_number, String
  attribute :contact_person, String
  attribute :backers, String
  attribute :collected, String
  attribute :payment_details, String
  attribute :overview, String

  validates :name,
            :birthday_on,
            :goal,
            :deadline_on,
            :payment_details,
             presence: true
  validates :budget, numericality: { greater_than: 0 }
  validate :birthday_on_in_the_past, :deadline_on_in_the_future

  MAX_AGE = 120
  MIN_DEADLINE_PERIOD = 7

  def initialize(account, params = {})
    @params = params
    super(account.attributes.merge(account_params))
    improve_input
  end

  private

  def birthday_on_in_the_past
    return if birthday_on.blank?

    errors.add(:birthday_on, :not_a_date) and return unless birthday_on.is_a?(Date)

    msg = I18n.t('.errors.account_form.birthday_on_in_the_past', count: MAX_AGE)
    errors.add(:birthday_on, msg) if birthday_on.blank? || birthday_on < MAX_AGE.years.ago || birthday_on > Date.yesterday
  end

  def deadline_on_in_the_future
    return if deadline_on.blank?

    errors.add(:deadline_on, :not_a_date) and return unless deadline_on.is_a?(Date)

    msg = I18n.t('.errors.account_form.deadline_on_in_the_future', count: MIN_DEADLINE_PERIOD)
    errors.add(:deadline_on, msg) if deadline_on.blank? || deadline_on < Date.today.days_since(MIN_DEADLINE_PERIOD)
  end

  def account_params
    params
      .require(:account)
      .permit(
        :name,
        :birthday_on,
        :goal,
        :budget,
        :deadline_on,
        :phone_number,
        :contact_person,
        :backers,
        :collected,
        :payment_details,
        :overview
      )
  end

  def improve_input
    self.name.squish!.downcase!.gsub!(/\w+/) { |word| word.capitalize } unless self.name.blank?

    self.goal.squish!.capitalize! unless self.goal.blank?
  end
end
