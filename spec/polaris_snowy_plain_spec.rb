require 'spec_helper.rb'
require 'polaris_snowy_plain.rb'

RSpec.describe Interpreter do
  let!(:interpreter) { Interpreter.new }
  before { interpreter.snowy_plain_initialize options }
  let(:options) { {} }

  describe 'snowy_plain_initialize' do
    context 'when no option is given' do
      it 'initializes all variables with default values' do
        expect($outer_circle_radius).to eq Interpreter::DEFAULT_OUTER_CIRCLE_RADIUS
        expect($inner_circle_radius).to eq Interpreter::DEFAULT_INNER_CIRCLE_RADIUS
        expect($hero_position_angle).to eq Interpreter::DEFAULT_ANGLE
        expect($hero_distance_from_base).to eq Interpreter::DEFAULT_OUTER_CIRCLE_RADIUS
        expect($hero_sight_angle).to eq Interpreter::DEFAULT_ANGLE
      end
    end

    context 'when options are given' do
      let(:options) { {:outer_circle_radius => 1, :inner_circle_radius => 2, :hero_position_angle => 3, :hero_distance_from_base => 4, :hero_sight_angle => 5} }

      it 'initializes all variables with these options' do
        expect($outer_circle_radius).to eq 1
        expect($inner_circle_radius).to eq 2
        expect($hero_position_angle).to eq 3
        expect($hero_distance_from_base).to eq 4
        expect($hero_sight_angle).to eq 5
      end
    end
  end

  describe 'snowy_plain_move_forward' do
    context 'when player has not reached the base yet' do
      before { expect(interpreter).to receive(:player_touches_base?).and_return(false) }

      context 'when player sight angle is equal zero' do
        before { expect(interpreter).to receive(:snowy_plain_move_to_direction).with($hero_sight_angle) }

        it { interpreter.snowy_plain_move_forward }
      end
    end

    context 'when player has reached the base' do
      before { expect(interpreter).to receive(:player_touches_base?).and_return(true) }

      context 'when player sight angle is equal zero' do
        before { expect(interpreter).not_to receive(:snowy_plain_move_to_direction) }

        it { interpreter.snowy_plain_move_forward }
      end
    end
  end

  describe 'snowy_plain_move_backwards' do
    context 'when player has not reached the limit yet' do
      before { expect(interpreter).to receive(:player_touches_outer_limit?).and_return(false) }

      context 'when player sight angle is equal zero' do
        before { expect(interpreter).to receive(:snowy_plain_move_to_direction).with(-$hero_sight_angle) }

        it { interpreter.snowy_plain_move_backwards }
      end
    end

    context 'when player has reached the limit' do
      before { expect(interpreter).to receive(:player_touches_outer_limit?).and_return(true) }

      context 'when player sight angle is equal zero' do
        before { expect(interpreter).not_to receive(:snowy_plain_move_to_direction) }

        it { interpreter.snowy_plain_move_backwards }
      end
    end
  end

  describe 'snowy_plain_move_to_direction' do
    let(:hero_distance_from_base) { 50 }

    before do
      $hero_position_angle = 0
      $hero_distance_from_base = hero_distance_from_base
      $hero_sight_angle = hero_sight_angle
    end

    subject { interpreter.snowy_plain_move_to_direction hero_sight_angle }

    context 'sight angle is lower than 90 deg' do
      let(:hero_sight_angle) { 45 }

      context 'half distance' do
        before { subject }

        it 'changes hero angle and position' do
          expect($hero_position_angle).to be > 0
          expect($hero_distance_from_base).to be < hero_distance_from_base
          expect($hero_sight_angle).to eq hero_sight_angle
        end
      end

      context 'on outer limit' do
        let(:hero_distance_from_base) { Interpreter::MIN_DISTANCE_FROM_BASE }

        before { subject }

        it 'changes hero angle and position' do
          expect($hero_position_angle).to be > 0
          expect($hero_distance_from_base).to eq hero_distance_from_base
          expect($hero_sight_angle).to eq hero_sight_angle
        end
      end
    end

    context 'sight angle is between 90 and 180 deg' do
      let(:hero_sight_angle) { 135 }

      context 'half distance' do
        before { subject }

        it 'changes hero angle and position' do
          expect($hero_position_angle).to be > 0
          expect($hero_distance_from_base).to be > hero_distance_from_base
          expect($hero_sight_angle).to eq hero_sight_angle
        end
      end

      context 'on outer limit' do
        let(:hero_distance_from_base) { Interpreter::DEFAULT_OUTER_CIRCLE_RADIUS }

        before { subject }

        it 'changes hero angle and position' do
          expect($hero_position_angle).to be > 0
          expect($hero_distance_from_base).to eq hero_distance_from_base
          expect($hero_sight_angle).to eq hero_sight_angle
        end
      end
    end

    context 'sight angle is between 180 and 270 deg' do
      let(:hero_sight_angle) { 225 }

      before { subject }

      it 'changes hero angle and position' do
        expect($hero_position_angle).to be < 0
        expect($hero_distance_from_base).to be > hero_distance_from_base
        expect($hero_sight_angle).to eq hero_sight_angle
      end
    end

    context 'sight angle is between 270 and 360 deg' do
      let(:hero_sight_angle) { 315 }

      before { subject }

      it 'changes hero angle and position' do
        expect($hero_position_angle).to be < 0
        expect($hero_distance_from_base).to be < hero_distance_from_base
        expect($hero_sight_angle).to eq hero_sight_angle
      end
    end
  end

  describe 'snowy_plain_turn_left' do
    context 'when angle is more than zero' do
      before { $hero_sight_angle = 90 }
      before { interpreter.snowy_plain_turn_left }

      it 'decreases hero sight angle' do
        expect($hero_sight_angle).to eq 89
      end
    end

    context 'when angle equals zero' do
      before { interpreter.snowy_plain_turn_left }

      it 'sets hero sight angle to 359' do
        expect($hero_sight_angle).to eq 359
      end
    end
  end

  describe 'snowy_plain_turn_right' do
    context 'when angle is less than 359' do
      before { $hero_sight_angle = 170 }
      before { interpreter.snowy_plain_turn_right }

      it 'increases hero sight angle' do
        expect($hero_sight_angle).to eq 171
      end
    end

    context 'when angle equals 359' do
      before { $hero_sight_angle = 359 }
      before { interpreter.snowy_plain_turn_right }

      it 'sets hero sight angle to 0' do
        expect($hero_sight_angle).to eq 0
      end
    end
  end

  describe 'snowy_plain_base_found?' do
    subject { interpreter.snowy_plain_base_found? }

    context 'when player is near base' do
      before { $hero_distance_from_base = Interpreter::MIN_DISTANCE_FROM_BASE }
      
      context 'when player looks at the base' do
        before { $hero_sight_angle = Interpreter::MAX_SIGHT_ANGLE - 1 }

        it { should eq true }
      end
      
      context 'when player looks at the base from the left' do
        before { $hero_sight_angle = 355 }

        it { should eq true }
      end

      context 'when player does not look at the base' do
        before { $hero_sight_angle = Interpreter::MAX_SIGHT_ANGLE + 1 }

        it { should eq false }
      end
    end

    context 'when player is not near base' do
      it { should eq false }
    end
  end
end