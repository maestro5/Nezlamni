require 'rails_helper'

RSpec.describe AccountForm do
  let(:id) { nil }
  let(:birthday) { }
  let(:deadline) { }
  let(:params) { {id: id, account: { birthday_on: birthday, deadline_on: deadline } } }
  let(:controller_parameters) { ActionController::Parameters.new(params) }
  
  subject { described_class.new(controller_parameters) }

  shared_examples_for 'date validation' do |attribute|
    it 'includes only birthday_on_in_the_past error message' do
      subject.valid?

      expect(subject.errors[attribute]).not_to include(error_blank)
      expect(subject.errors[attribute]).not_to include(error_not_a_date)
      expect(subject.errors[attribute]).to include(expected_error)
    end
  end

  context 'when invalid params' do
    let(:max_age) { described_class::MAX_AGE }
    let(:min_deadline_period) { described_class::MIN_DEADLINE_PERIOD }
    let(:date_today) { Date.today }
    let(:date_tomorrow) { Date.tomorrow }
    let(:date_yesterday) { Date.yesterday }
    let(:date_a_day_before_deadline) { date_today.days_since(min_deadline_period - 1) }
    let(:error_blank) { I18n.t('.errors.messages.blank') }
    let(:error_not_a_date) { I18n.t('.errors.messages.not_a_date') }
    let(:error_not_a_number) { I18n.t('.errors.messages.not_a_number') }
    let(:error_birthday_on_in_the_past) do
      I18n.t('.errors.account_form.birthday_on_in_the_past', count: max_age)
    end
    let(:error_deadline_on_in_the_future) do
      I18n.t('.errors.account_form.deadline_on_in_the_future', count: min_deadline_period)
    end

    it "returns false" do
      expect(subject.valid?).to be false
    end

    it "returns errors" do
      subject.valid?

      expect(subject.errors[:name]).to            include(error_blank)
      expect(subject.errors[:birthday_on]).to     include(error_blank)
      expect(subject.errors[:goal]).to            include(error_blank)
      expect(subject.errors[:deadline_on]).to     include(error_blank)
      expect(subject.errors[:payment_details]).to include(error_blank)
      expect(subject.errors[:budget]).to          include(error_not_a_number)
    end

    context "when birthday" do
      let(:expected_error) { error_birthday_on_in_the_past }
    
      context 'is today' do
        let(:birthday) { date_today }

        it_behaves_like 'date validation', :birthday_on
      end

      context 'is in the future' do
        let(:birthday) { date_tomorrow }

        it_behaves_like 'date validation', :birthday_on
      end

      context "is later than MAX_AGE years old" do
        let(:birthday) { max_age.years.ago.to_date }

        it_behaves_like 'date validation', :birthday_on
      end
    end

    context "when deadline" do
      let(:expected_error) { error_deadline_on_in_the_future }

      context "when deadline is today" do
        let(:deadline) { date_today }

        it_behaves_like 'date validation', :deadline_on
      end

      context "when deadline is in the past" do
        let(:deadline) { date_yesterday }

        it_behaves_like 'date validation', :deadline_on
      end

      context "when deadline is less than min deadline period" do
        let(:deadline) { date_a_day_before_deadline }

        it_behaves_like 'date validation', :deadline_on
      end
    end
  end

  context 'when valid params' do
    let(:valid_name) { 'Dagny Taggart' }
    let(:valid_goal) { 'Needs hospitalization' }
    let(:inaccurate_name) { '    daGnY    TAGgarT   ' }
    let(:inaccurate_goal) { '    nEEds      hospitaliZation   ' }
    let(:params) do
      { 
        account: attributes_for(:account,
          name: inaccurate_name,
          goal: inaccurate_goal) 
      }
    end

    it "returns true" do
      expect(subject.valid?).to be true
    end

    it "doesn't have errors" do
      subject.valid?

      expect(subject.errors).to be_empty
    end

    it "has valid name" do
      expect(subject.name).to eq valid_name
    end

    it "has valid goal" do
      expect(subject.goal).to eq valid_goal
    end
  end

  # context '#update' do
  #   let(:name) { 'John Galt' }
  #   let(:new_name) { 'Henry Rearden' }
  #   let(:account) { Account.create(name: name) }
  #   let(:id) { account.id }

  #   context 'when invalid' do
  #     it "returns false" do
  #       expect(subject.update).to be false
  #     end

  #     it "contains errors" do
  #       subject.update

  #       expect(subject.errors).not_to be_empty
  #     end

  #     it "doesn't change db record" do
  #       expect { subject.update }.not_to change { account.reload.name }
  #     end
  #   end

  #   context 'when valid' do
  #     let(:params) { {id: id, account: attributes_for(:account, name: new_name) } }

  #     it "returns true" do
  #       expect(subject.update).to be true
  #     end

  #     it "contains errors" do
  #       subject.update

  #       expect(subject.errors).to be_empty
  #     end

  #     it "doesn't change db record" do
  #       expect { subject.update }.to change { account.reload.name }
  #     end
  #   end
  # end
end
