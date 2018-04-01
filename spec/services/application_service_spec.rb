require 'rails_helper'
require_relative '../support/shared/application_service_interface_spec'

RSpec.describe ApplicationService do
  subject { described_class.new }
  
  it_behaves_like 'application service'
end
