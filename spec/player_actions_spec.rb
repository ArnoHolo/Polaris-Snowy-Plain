require 'spec_helper.rb'
require 'polaris_snowy_plain.rb'

RSpec.describe IntroPlain::PlayerActions do
  let(:player_actions) { IntroPlain::PlayerActions.new }
  before { $snowy_plain = SnowyPlain.new }

  describe 'key_entered' do
    before do
      class_double("Input").as_stubbed_const
      stub_const("Input::UP", :input_up)
      stub_const("Input::DOWN", :input_down)
      stub_const("Input::LEFT", :input_left)
      stub_const("Input::RIGHT", :input_right)
      stub_const("Input::A", :input_a)
    end

    before { expect($snowy_plain).to receive(:display_base) }

    before { expect(Input).to receive(:press?).with(:input_a).and_return(pressed_input_a) }
    let(:pressed_input_a) { false }

    context 'when player enters UP key' do
      before { expect(Input).to receive(:dir4).and_return(:input_up) }

      before { expect($snowy_plain).to receive(:move_forward) }
      before { expect($snowy_plain).not_to receive(:information) }

      it { player_actions.key_entered }
    end

    context 'when player enters DOWN key' do
      before { expect(Input).to receive(:dir4).and_return(:input_down) }

      before { expect($snowy_plain).to receive(:move_backwards) }
      before { expect($snowy_plain).not_to receive(:information) }

      it { player_actions.key_entered }
    end

    context 'when player enters LEFT key' do
      before { expect(Input).to receive(:dir4).and_return(:input_left) }

      before { expect($snowy_plain).to receive(:turn_left) }
      before { expect($snowy_plain).not_to receive(:information) }

      it { player_actions.key_entered }
    end

    context 'when player enters RIGHT key' do
      before { expect(Input).to receive(:dir4).and_return(:input_right) }

      before { expect($snowy_plain).to receive(:turn_right) }
      before { expect($snowy_plain).not_to receive(:information) }

      it { player_actions.key_entered }
    end

    context 'when player enters A key' do
      let(:pressed_input_a) { true }

      before { expect(Input).to receive(:dir4) }

      before { expect($snowy_plain).to receive(:information) }

      it { player_actions.key_entered }
    end
  end
end