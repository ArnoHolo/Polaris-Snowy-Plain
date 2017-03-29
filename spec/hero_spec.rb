require 'spec_helper.rb'
require 'polaris_snowy_plain.rb'

RSpec.describe IntroPlain::Hero do
  let(:hero) { IntroPlain::Hero.new }
  before { $snowy_plain = SnowyPlain.new }

  describe 'move_forward' do
    context 'when hero has not reached the base yet' do
      before { expect($snowy_plain).to receive(:hero_touches_base?).and_return(false) }

      context 'when hero sight angle is equal zero' do
        before { expect($snowy_plain).to receive(:move_to_direction).with($snowy_plain.hero_sight_angle) }

        it { hero.move_forward }
      end
    end

    context 'when hero has reached the base' do
      before { expect($snowy_plain).to receive(:hero_touches_base?).and_return(true) }

      context 'when hero sight angle is equal zero' do
        before { expect($snowy_plain).not_to receive(:move_to_direction) }

        it { hero.move_forward }
      end
    end
  end

  describe 'move_backwards' do
    context 'when hero has not reached the limit yet' do
      before { expect($snowy_plain).to receive(:hero_touches_outer_limit?).and_return(false) }

      context 'when hero sight angle is equal zero' do
        before { expect($snowy_plain).to receive(:move_to_direction).with(-$snowy_plain.hero_sight_angle) }

        it { hero.move_backwards }
      end
    end

    context 'when hero has reached the limit' do
      before { expect($snowy_plain).to receive(:hero_touches_outer_limit?).and_return(true) }

      context 'when hero sight angle is equal zero' do
        before { expect($snowy_plain).not_to receive(:move_to_direction) }

        it { hero.move_backwards }
      end
    end
  end

  describe 'turn_left' do
    context 'when angle is more than zero' do
      before { $snowy_plain.hero_sight_angle = 90 }
      before { hero.turn_left }

      it 'decreases hero sight angle' do
        expect($snowy_plain.hero_sight_angle).to eq 89
      end
    end

    context 'when angle equals zero' do
      before { hero.turn_left }

      it 'sets hero sight angle to 359' do
        expect($snowy_plain.hero_sight_angle).to eq 359
      end
    end
  end

  describe 'turn_right' do
    context 'when angle is less than 359' do
      before { $snowy_plain.hero_sight_angle = 170 }
      before { hero.turn_right }

      it 'increases hero sight angle' do
        expect($snowy_plain.hero_sight_angle).to eq 171
      end
    end

    context 'when angle equals 359' do
      before { $snowy_plain.hero_sight_angle = 359 }
      before { hero.turn_right }

      it 'sets hero sight angle to 0' do
        expect($snowy_plain.hero_sight_angle).to eq 0
      end
    end
  end
end