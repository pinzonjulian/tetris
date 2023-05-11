
# [
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
#   [0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
# ]

class Grid
  class OverflowXError < StandardError; end;
  class OverflowYError < StandardError; end;

  def initialize(width:, height:)
    @width = width
    @height = height
    @cells = []
    build_grid
  end

  attr_reader :cells, :width, :height

  def plant_piece(x:, y:, piece:)
    raise OverflowXError if (x + piece.first.size) > width
    if (y + piece.first.size) > height
      raise OverflowYError
    end

    piece.each_with_index do |piece_row, piece_row_i|
      piece_row.each_with_index do |_, piece_column_i|
        plant_x = x + piece_row_i
        plant_y = y + piece_column_i
        cells[plant_x][plant_y] = piece[piece_row_i][piece_column_i]
      end
    end
  end

  def already_occupied?(x:, y:, piece: )
    piece.each_with_index do |piece_row, piece_row_i|
      piece_row.each_with_index do |_, piece_column_i|
        new_x = x + piece_row_i
        new_y = y + piece_column_i
        cell_to_check = cells[new_x][new_y]

        return true if cell_to_check != 0
      end
    end
    return false
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