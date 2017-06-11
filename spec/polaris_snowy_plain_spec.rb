require 'spec_helper.rb'
require 'polaris_snowy_plain.rb'

RSpec.describe SnowyPlain do
  let(:snowy_plain) { SnowyPlain.new options }
  let(:options) { {} }

  before do
    $snowy_plain_plain = IntroPlain::Plain.new
    $snowy_plain_hero = IntroPlain::Hero.new
  end

  describe 'initialize_variables' do
    context 'when no option is given' do
      it 'initializes all variables with default values' do
        expect(snowy_plain.inner_circle_radius).to eq SnowyPlain::DEFAULT_INNER_CIRCLE_RADIUS
        expect(snowy_plain.hero_position_angle).to eq IntroPlain::Hero::DEFAULT_ANGLE
        expect(snowy_plain.hero_distance_from_base).to eq IntroPlain::Plain::DEFAULT_RADIUS
      end
    end

    context 'when options are given' do
      let(:options) { {:inner_circle_radius => 2, :hero_position_angle => 3, :hero_distance_from_base => 4} }

      it 'initializes all variables with these options' do
        expect(snowy_plain.inner_circle_radius).to eq 2
        expect(snowy_plain.hero_position_angle).to eq 3
        expect(snowy_plain.hero_distance_from_base).to eq 4
      end
    end
  end

  describe 'base_found?' do
    subject { snowy_plain.base_found? }

    context 'when hero is near base' do
      before { snowy_plain.hero_distance_from_base = SnowyPlain::MIN_DISTANCE_FROM_BASE }
      
      context 'when hero looks at the base' do
        before { $snowy_plain_hero.sight_angle = SnowyPlain::MAX_SIGHT_ANGLE - 1 }

        it { should eq true }
      end
      
      context 'when hero looks at the base from the left' do
        before { $snowy_plain_hero.sight_angle = 355 }

        it { should eq true }
      end

      context 'when hero does not look at the base' do
        before { $snowy_plain_hero.sight_angle = SnowyPlain::MAX_SIGHT_ANGLE + 1 }

        it { should eq false }
      end
    end

    context 'when hero is not near base' do
      it { should eq false }
    end
  end

  # Private

  describe 'base_x_position' do
    context 'when hero looks a bit on the left' do
      before { $snowy_plain_hero.sight_angle = 360 - SnowyPlain::WIDE_SIGHT_ANGLE / 2 }

      subject { snowy_plain.send(:base_x_position) }

      it { should be > 320 }
    end

    context 'when hero looks at the left limit' do
      before { $snowy_plain_hero.sight_angle = 360 - SnowyPlain::WIDE_SIGHT_ANGLE + 1 }

      subject { snowy_plain.send(:base_x_position) }

      it { should be > 480 }
    end

    context 'when hero looks a bit on the right' do
      before { $snowy_plain_hero.sight_angle = SnowyPlain::WIDE_SIGHT_ANGLE / 2 }

      subject { snowy_plain.send(:base_x_position) }

      it { should be < 320 }
    end

    context 'when hero looks at the right limit' do
      before { $snowy_plain_hero.sight_angle = SnowyPlain::WIDE_SIGHT_ANGLE - 1 }

      subject { snowy_plain.send(:base_x_position) }

      it { should be < 160 }
    end
  end

  describe 'move_to_direction' do
    let(:hero_distance_from_base) { 50 }

    before do
      snowy_plain.hero_position_angle = 0
      snowy_plain.hero_distance_from_base = hero_distance_from_base
      $snowy_plain_hero.sight_angle = hero_sight_angle
    end

    subject { snowy_plain.send(:move_to_direction, hero_sight_angle) }

    context 'sight angle is lower than 90 deg' do
      let(:hero_sight_angle) { 45 }

      context 'half distance' do
        before { subject }

        it 'changes hero angle and position' do
          expect(snowy_plain.hero_position_angle).to be > 0
          expect(snowy_plain.hero_distance_from_base).to be < hero_distance_from_base
          expect($snowy_plain_hero.sight_angle).to eq hero_sight_angle
        end
      end

      context 'on outer limit' do
        let(:hero_distance_from_base) { SnowyPlain::MIN_DISTANCE_FROM_BASE }

        before { subject }

        it 'changes hero angle and position' do
          expect(snowy_plain.hero_position_angle).to be > 0
          expect(snowy_plain.hero_distance_from_base).to eq hero_distance_from_base
          expect($snowy_plain_hero.sight_angle).to eq hero_sight_angle
        end
      end
    end

    context 'sight angle is between 90 and 180 deg' do
      let(:hero_sight_angle) { 135 }

      context 'half distance' do
        before { subject }

        it 'changes hero angle and position' do
          expect(snowy_plain.hero_position_angle).to be > 0
          expect(snowy_plain.hero_distance_from_base).to be > hero_distance_from_base
          expect($snowy_plain_hero.sight_angle).to eq hero_sight_angle
        end
      end

      context 'on outer limit' do
        let(:hero_distance_from_base) { IntroPlain::Plain::DEFAULT_RADIUS }

        before { subject }

        it 'changes hero angle and position' do
          expect(snowy_plain.hero_position_angle).to be > 0
          expect(snowy_plain.hero_distance_from_base).to eq hero_distance_from_base
          expect($snowy_plain_hero.sight_angle).to eq hero_sight_angle
        end
      end
    end

    context 'sight angle is between 180 and 270 deg' do
      let(:hero_sight_angle) { 225 }

      before { subject }

      it 'changes hero angle and position' do
        expect(snowy_plain.hero_position_angle).to be < 0
        expect(snowy_plain.hero_distance_from_base).to be > hero_distance_from_base
        expect($snowy_plain_hero.sight_angle).to eq hero_sight_angle
      end
    end

    context 'sight angle is between 270 and 360 deg' do
      let(:hero_sight_angle) { 315 }

      before { subject }

      it 'changes hero angle and position' do
        expect(snowy_plain.hero_position_angle).to be < 0
        expect(snowy_plain.hero_distance_from_base).to be < hero_distance_from_base
        expect($snowy_plain_hero.sight_angle).to eq hero_sight_angle
      end
    end
  end

  describe 'information' do
    before { expect(snowy_plain).to receive(:print) }

    it { snowy_plain.send(:information) }
  end
end