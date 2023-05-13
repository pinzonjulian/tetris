class Piece
  TETROMINOES =   {
    I: [[1, 1, 1, 1]],
    O: [[2, 2], [2, 2]],
    T: [[0, 3], [3, 3], [0, 3]],
    J: [[4, 4], [0, 4], [0, 4]],
    L: [[5, 5], [5, 0], [5, 0]],
    S: [[0, 6], [6, 6], [6, 0]],
    Z: [[7, 0], [7, 7], [0, 7]],
  }

  class << self
    def random
      new(name: TETROMINOES.keys[rand(6)])
    end
  end

  def initialize(name:)
    @name = name
    @matrix = TETROMINOES[name]
  end
  attr_reader :matrix, :name

  def width
    matrix.size
  end

  def height
    matrix.first.size
  end

  def rotate_left
    transpose
  end
  def rotate_right
    transpose
    transpose
    transpose
  end

  private

  def transpose
    @matrix = matrix.transpose.map(&:reverse)
  end
end