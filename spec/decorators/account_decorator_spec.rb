require 'rails_helper'

RSpec.describe AccountDecorator do
  let(:name) { 'John Galt' }
  let(:goal) { 'Treatment' }
  let(:age) { 14 }
  let(:collected_percent) { 37.03 }
  let(:account) do
    OpenStruct.new(
      name: name,
      birthday_on: '15/07/2003'.to_date,
      goal: goal,
      budget: 2100.71,
      collected: 777.99
    )
  end

  subject { described_class.new account }  

  describe '#age' do
    it 'is returns blank string when birthday_on is nil' do
      account.birthday_on = nil

      expect(subject.age).to eq ''
    end

    it 'is returns blank string when birthday_on is not a date' do
      account.birthday_on = 19

      expect(subject.age).to eq ''
    end

    it 'is returns correct age' do
      expect(subject.age).to eq age
    end
  end

  describe '#title' do
    it "is returns blank string, when name is blank" do
      account.name = nil

      expect(subject.title).to eq ''
    end

    it "is returns name only, when age and goal are blank" do
      account.goal = nil
      allow_any_instance_of(described_class).to receive(:age).and_return('')

      expect(subject.title).to eq name
    end

    it "is returns name and age, when goal is blank" do
      account.goal = nil

      expect(subject.title).to eq "#{name}, #{age}"
    end

    it "is returns name and goal, when age is blank" do
      allow_any_instance_of(described_class).to receive(:age).and_return('')

      expect(subject.title).to eq "#{name}. #{goal}"
    end

    it "is returns full title" do
      expect(subject.title).to eq "#{name}, #{age}. #{goal}"
    end
  end

  describe '#collected_percent' do
    context 'when budget is invalid' do
      it "is returns 0.0 when budget is nil" do
        account.budget = nil

        expect(subject.collected_percent).to eq 0.0
      end

      it "is returns 0.0 when budget is 0" do
        account.budget = 0

        expect(subject.collected_percent).to eq 0.0
      end

      it "is returns 0.0 when budget less when 0" do
        account.budget = -999.99

        expect(subject.collected_percent).to eq 0.0
      end

      it "is returns 0.0 when budget is not a number" do
        account.budget = 'tExt'

        expect(subject.collected_percent).to eq 0.0
      end
    end

    context 'when collected is invalid' do
      it "is returns 0.0 when collected is nil" do
        account.collected = nil

        expect(subject.collected_percent).to eq 0.0
      end

      it "is returns 0.0 when collected is 0" do
        account.collected = 0

        expect(subject.collected_percent).to eq 0.0
      end

      it "is returns 0.0 when collected less when 0" do
        account.collected = -999.99

        expect(subject.collected_percent).to eq 0.0
      end

      it "is returns 0.0 when collected is not a number" do
        account.collected = 'tExt'

        expect(subject.collected_percent).to eq 0.0
      end
    end

    it "is returns correct collected percent" do
      expect(subject.collected_percent).to eq collected_percent
    end
  end
end
