class Grid
  class OverflowXError < StandardError; end;
  class OverflowYError < StandardError; end;

  GRID_START = 0

  def initialize(width:, height:)
    @width = width
    @height = height
    @cells = []
    build_grid
  end

  attr_reader :cells, :width, :height

  def plant_piece(x:, y:, piece:)
    raise OverflowXError if (x + piece.width) > width
    if (y + piece.height) > height + 1
      raise OverflowYError
    end

    piece.matrix.each_with_index do |piece_row, piece_row_i|
      piece_row.each_with_index do |_, piece_column_i|
        plant_x = x + piece_row_i
        plant_y = y + piece_column_i
        cells[plant_x][plant_y] = piece.matrix[piece_row_i][piece_column_i]
      end
    end
  end

  def already_occupied?(x:, y:, piece: )
    piece.matrix.each_with_index do |piece_row, piece_row_i|
      piece_row.each_with_index do |value, piece_column_i|
        next if value.zero?

        new_x = x + piece_row_i
        new_y = y + piece_column_i

        cell_to_check = cells[new_x][new_y]

        result = cell_to_check != 0
        return true if result
      end
    end
    return false
  end

  def reached_bottom?(piece:, y:)
    y + piece.height == height
  end

  def out_of_bottom_bound?(piece:, y:)
    (y + piece.height) >= height
  end

  def out_of_right_bound?(piece:, x:)
    (x + piece.width) > width
  end

  def out_of_left_bound?(x)
    x < GRID_START
  end

  private

  def build_grid
    rows = (0..(@height - 1))
    columns = (0..(@width - 1))

    columns.each do |column|
      cells[column] = []
      rows.each do |row|
        cells[column][row] = 0
      end
    end
  end

end