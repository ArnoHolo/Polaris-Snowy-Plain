require 'spec_helper.rb'
require 'polaris_snowy_plain.rb'

RSpec.describe IntroPlain::Plain do
  let(:plain) { IntroPlain::Plain.new options }
  let(:options) { {} }
  before { $snowy_plain = SnowyPlain.new }

  describe 'initialize_variables' do
    context 'when no option is given' do
      it 'initializes all variables with default values' do
        expect(plain.radius).to eq IntroPlain::Plain::DEFAULT_RADIUS
      end
    end

    context 'when options are given' do
      let(:options) { {:radius => 1} }

      it 'initializes all variables with these options' do
        expect(plain.radius).to eq 1
      end
    end
  end
end