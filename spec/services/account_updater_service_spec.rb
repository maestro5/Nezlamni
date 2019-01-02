require 'rails_helper'
require_relative '../support/shared/application_service_interface_spec'

RSpec.describe AccountUpdaterService do
  let(:name) { 'Bob' }
  let(:params) { {account: {name: name}} }
  let(:controller_parameters) { ActionController::Parameters.new(params) }
  let(:account) { Account.create }
  let(:account_form) { AccountForm.new(controller_parameters) }

  subject { described_class.new(account: account, account_form: account_form).update }

  it_behaves_like 'application service'

  describe '#update' do
    context "when invalid params" do
      it 'returns false' do
        expect(subject).to be false
      end

      it "doesn't save changes in db" do
        expect{subject}.not_to change(account.reload, :name)
      end

      it "includes account errors" do
        subject
        expect(account.errors).not_to be_empty
      end

      it "does'nt creates an account default product" do
        expect{subject}.not_to change(account.products, :count)
      end
    end

    context "when valid params" do
      let(:params) { { account: attributes_for(:account, name: name) } }

      it "returns true" do
        expect(subject).to be true
      end

      it "saves changes in db" do
        expect{subject}.to change(account.reload, :name).from('').to(name)
      end

      it "doesn't includes account errors" do
        subject
        expect(account.errors).to be_empty
      end

      it "creates account default product" do
        expect{subject}.to change(account.products, :count).by(1)
      end
    end
  end
end
