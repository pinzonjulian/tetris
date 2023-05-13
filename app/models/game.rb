require "app/models/grid.rb"
require "app/models/piece.rb"

class Game
  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720
  GRID_COLUMNS = 10
  GRID_ROWS = 20
  CUBE_SIZE = 30
  COLORS = [
    [255, 255, 255], # white
    [255, 0, 0], # red
    [0, 255, 0], # green
    [0, 0, 255], # blue
    [255, 255, 0], # yellow
    [0, 255, 255], # teal
    [255, 0, 255], # magenta
    [170, 170, 170], # gray
    [100,100,100] # dark_gray
  ]

  def initialize(args)
    @args = args
    @tick_rate = 30
    @next_move = @tick_rate
    @score = 0
    @game_ended = false
    @keyboard = args.inputs.keyboard
    @controller_one = args.inputs.controller_one
    @grid = Grid.new(width: GRID_COLUMNS, height: GRID_ROWS)

    reset_position_for_next_piece
    @current_piece = select_next_piece

    build_grid
  end

  attr_reader :current_piece_x, :current_piece_y, :current_piece

  def tick
    debug
    iterate
    render
    nil
  end

  def debug
    if keyboard.key_down.pageup || keyboard.key_held.pageup
      @tick_rate += 1
    end
    if keyboard.key_down.pagedown || keyboard.key_held.pagedown
      @tick_rate -= 1 unless @tick_rate == 1
    end
    if keyboard.key_down.r
      $gtk.reset
    end
    @args.outputs.labels << [100, 600, "@tick_rate = #{@tick_rate}", 255,     128,  128,   255]
    @args.outputs.labels << [100, 500, "@current_piece_x = #{@current_piece_x}", 255,     128,  128,   255]
    @args.outputs.labels << [100, 400, "@current_piece_y = #{@current_piece_y}", 255,     128,  128,   255]
  end

  attr_accessor :grid

  private

  attr_reader :keyboard, :controller_one

  def iterate
    move_left
    move_right
    move_down
    rotate_left
    rotate_right

    @next_move -= 1
    return unless @next_move.zero?

    if collision_detected?
      plant_current_piece
      reset_position_for_next_piece
      select_next_piece
    else
      move_current_piece_down
    end
    reset_tick_rate
  end

  def rotate_left
    return unless rotate_left_detected?

    @current_piece.rotate_left

    if @current_piece_x + @current_piece.width >= GRID_COLUMNS
      @current_piece_x = @current_piece_x - @current_piece.width + 3
    end
  end

  def rotate_right
    return unless rotate_right_detected?

    @current_piece.rotate_right

    if (@current_piece_x + @current_piece.width) >= GRID_COLUMNS
      @current_piece_x = @current_piece_x - @current_piece.width
    end
  end

  def rotate_left_detected?
    keyboard.key_down.a || controller_one.a
  end

  def rotate_right_detected?
    keyboard.key_down.s || controller_one.b
  end

  def reset_position_for_next_piece
    @current_piece_x = 5
    @current_piece_y = 0
  end

  def move_left
    return unless left_movement_detected?
    return if piece_detected_left?
    return if out_of_left_bound?

    @current_piece_x -= 1
  end

  def left_movement_detected?
    keyboard.key_down.left || controller_one.key_down.left
  end

  def piece_detected_left?
    @current_piece.matrix.each_with_index do |row, row_i|
      row.each_with_index do |_, col_i|
        next if @current_piece.matrix[row_i][col_i] == 0

        x = @current_piece_x - 1
        y = @current_piece_y + 1
        return true if grid.cells[x][y] != 0
      end
    end
    return false
  end

  def move_right
    return unless right_movement_detected?
    return if out_of_right_bounds?
    return if piece_detected_right?

    @current_piece_x += 1
  end

  def right_movement_detected?
    keyboard.key_down.right || controller_one.key_down.right
  end

  def piece_detected_right?
    @current_piece.matrix.each_with_index do |row, row_i|
      row.each_with_index do |_, col_i|
        next if @current_piece.matrix[row_i][col_i].nil? || @current_piece.matrix[row_i][col_i] == 0

        x = @current_piece_x + @current_piece.width
        y = @current_piece_y + @current_piece.height

        return true if grid.cells[x][y] != 0
      end
    end
    return false
  end

  def out_of_left_bound?
    attempted_x = @current_piece_x - 1
    grid.out_of_left_bound?(attempted_x)
  end

  def out_of_right_bounds?
    attempted_x = @current_piece_x + 1
    grid.out_of_right_bound?(x: attempted_x, piece: @current_piece)
  end

  def move_down
    return if collision_detected?
    return unless down_movement_detected?

    @current_piece_y += 1
  end

  def down_movement_detected?
    keyboard.key_down.down ||
      keyboard.key_held.down ||
      controller_one.key_down.down ||
      controller_one.key_held.down
  end

  def render
    render_background
    render_grid
    render_current_piece
  end

  def select_next_piece
    Piece.random
  end

  def plant_current_piece
    grid.plant_piece(x: @current_piece_x, y: @current_piece_y, piece: @current_piece)
  end

  def collision_detected?
    current_piece_reached_bottom? || space_already_occupied?
  end

  def space_already_occupied?
    grid.already_occupied?(x: @current_piece_x, y: @current_piece_y + 1, piece: @current_piece)
  end

  def current_piece_reached_bottom?
    grid.reached_bottom?(piece: @current_piece, y: @current_piece_y)
  end

  def move_current_piece_down
    @current_piece_y += 1
  end

  def reset_tick_rate
    @next_move = @tick_rate
  end

  def render_current_piece
    @current_piece.matrix.each_with_index do |column, column_i|
      column.each_with_index do |value, row_i|
        render_cube(@current_piece_x + column_i, @current_piece_y + row_i, color: value) unless @current_piece.matrix[column_i][row_i].zero?
      end
    end
  end

  def build_grid
    rows = (0..(GRID_ROWS - 1))
    columns = (0..(GRID_COLUMNS - 1))

    columns.each do |column|
      grid.cells[column] = []
      rows.each do |row|
        grid.cells[column][row] = 0
      end
    end
  end

  def render_background
    @args.outputs.solids << [0,0, SCREEN_WIDTH, SCREEN_HEIGHT, [0,0,0]]
    render_grid_border
  end

  def render_grid_border
    (GRID_ROWS + 2).times do |i|
      render_cube(-1, i - 1, color: 8)
      render_cube(GRID_COLUMNS, i - 1, color: 8)
    end

    (GRID_COLUMNS + 2).times do |i|
      render_cube(i - 1, -1, color: 8)
      render_cube(i - 1, GRID_ROWS, color: 8)
    end
  end

  def render_grid
    grid.cells.each_with_index do |row, x|
      row.each_with_index do |value, y|
        render_cube(x, y, color: value) unless grid.cells[x][y].zero?
      end
    end
  end

  def render_cube(x, y, color: 0)
    grid_x = (1280 - (GRID_COLUMNS * CUBE_SIZE)) / 2
    grid_y = (720 - (GRID_ROWS * CUBE_SIZE)) / 2
    cube_x = grid_x + (x * CUBE_SIZE)
    cube_y = (720 - grid_y) - (y * CUBE_SIZE)
    @args.outputs.solids << [cube_x, cube_y, CUBE_SIZE, CUBE_SIZE, *COLORS[color]]
    @args.outputs.borders << [cube_x, cube_y, CUBE_SIZE, CUBE_SIZE, *COLORS[0]]
  end

end