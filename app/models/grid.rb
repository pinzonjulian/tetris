class Grid
  class OverflowXError < StandardError; end;
  class OverflowYError < StandardError; end;

  GRID_START = 0

  def initialize(width:, height:)
    @width = width
    @height = height
    @cells = []
    @cleared_rows_count = 0
    build_grid
  end

  attr_reader :cells, :width, :height, :cleared_rows_count

  def plant_piece(piece:, x:, y:)
    raise OverflowXError if (x + piece.width) > width
    if (y + piece.height) > height + 1
      raise OverflowYError
    end

    piece.matrix.each_with_index do |piece_row, piece_row_i|
      piece_row.each_with_index do |_, piece_column_i|
        plant_x = x + piece_row_i
        plant_y = y + piece_column_i
        cell_to_stamp = piece.matrix[piece_row_i][piece_column_i]
        next if cell_to_stamp.zero?
        cells[plant_x][plant_y] = cell_to_stamp
      end
    end
  end

  def already_occupied?(piece:, x:, y: )
    piece.matrix.each_with_index do |piece_row, piece_row_i|
      piece_row.each_with_index do |value, piece_column_i|
        next if value.zero?

        new_x = x + piece_row_i
        new_y = y + piece_column_i

        raise OverflowXError if new_x >= width

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

  def completed_rows?
    cells.transpose.reverse.any? do |row|
      row.none?(0)
    end
  end

  def clear_completed_rows
    new_cells = []

    cells.transpose.each do |row|
      if row.any?(0)
        new_cells << row
        next
      end
      @cleared_rows_count += 1
      new_cells.prepend [0,0,0,0,0,0,0,0,0,0]
    end

    @cells = new_cells.transpose
  end

  def reset_cleared_rows_count
    @cleared_rows_count = 0
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