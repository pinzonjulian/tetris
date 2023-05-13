require "spec_helper"
require "./app/models/grid"
require "./app/models/piece"

RSpec.describe Grid do
  let(:width) { 10 }
  let(:height) { 20 }
  let(:x) { 8 }
  let(:y) { 18 }
  let(:grid_instance) { described_class.new(width: width, height: height) }

  subject { grid_instance }

  it "is initialized properly" do
    expect(subject.cells.size).to eq 10
    expect(subject.cells.first.size).to eq 20
  end

  describe "#plant_piece" do
    let(:square_piece) { Piece.new(name: :O) }

    it "saves a piece into the grid in the correct position" do
      subject.plant_piece(x: x, y: y, piece: square_piece)

      result = [
        subject.cells[8][18], subject.cells[8][19],
        subject.cells[9][18], subject.cells[9][19]
      ].none?(0)

      expect(result).to be true
    end

    context "Border detection" do
      context "when attempting to plant outside of the x axis" do
        let(:x) { 10 }

        it "raises an exception" do
          expect { subject.plant_piece(x: x, y: y, piece: square_piece) }.to raise_error(Grid::OverflowXError)
        end
      end

      context "when attempting to plant outside of the y axis" do
        let(:y) { 20 }

        it "raises an exception" do
          expect { subject.plant_piece(x: x, y: y, piece: square_piece) }.to raise_error(Grid::OverflowYError)
        end
      end
    end

    context "When the grid already has a planted piece" do
      before do
        subject.plant_piece(x: x, y: y, piece: square_piece)
      end
    end
  end

  describe "#already_occupied?" do
    subject { grid_instance.already_occupied?(x: incoming_x, y: incoming_y, piece: piece) }

    before do
      grid_instance.plant_piece(x: 4, y: 18, piece: piece)
    end

    describe "when the incoming piece is a square" do
      let(:piece) { Piece.new(name: :O) }

      context "and it's above but not touching" do
        let(:incoming_x) { 4 }
        let(:incoming_y) { 16 }

        it { is_expected.to be false }
      end
      context "and it's overlapping only in one cell on the left" do
        let(:incoming_x) { 3 }
        let(:incoming_y) { 17 }

        it { is_expected.to be true }
      end

      context "and an incoming one is overlapping by two cells on the left" do
        let(:incoming_x) { 3 }
        let(:incoming_y) { 18 }

        it { is_expected.to be true }
      end

      context "and it's overlapping only in one cell on the right" do
        let(:incoming_x) { 5 }
        let(:incoming_y) { 17 }

        it { is_expected.to be true }
      end

      context "and it's overlapping by two cells on the right" do
        let(:incoming_x) { 5 }
        let(:incoming_y) { 18 }

        it { is_expected.to be true }
      end
    end
    describe "when the incoming piece is a rotated J" do
      before do
        initial_piece = Piece.new(name: :J)
        initial_piece.rotate_left
        initial_piece.rotate_left
        grid_instance.plant_piece(x: 0, y: 18, piece: initial_piece)
        piece.rotate_left
        piece.rotate_left
      end

      let(:piece) { Piece.new(name: :J) }
      let(:incoming_x) { 1 }
      let(:incoming_y) { 17 }

      it { is_expected.to be false }

    end
  end
end