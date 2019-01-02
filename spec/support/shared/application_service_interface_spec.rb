shared_examples_for 'application service' do
  it 'responds to perform' do
    expect(subject).to respond_to(:perform)
  end

  it 'responds to success' do
    expect(subject).to respond_to(:success?)
  end

  it 'responds to resource' do
    expect(subject).to respond_to(:resource)
  end
end
