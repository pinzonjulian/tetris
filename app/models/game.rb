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
    [100, 100, 100, 70] # dark_gray
  ]

  def initialize(args)
    @args = args
    start_game
  end

  def start_game
    @tick_rate = 30
    @next_move = @tick_rate
    @score = 0
    @game_ended = false
    @keyboard = args.inputs.keyboard
    @controller_one = args.inputs.controller_one
    @grid = Grid.new(width: GRID_COLUMNS, height: GRID_ROWS)
    @ended = false

    reset_position_for_next_piece
    set_next_piece
    set_future_piece

    build_grid
  end

  attr_reader :args
  attr_reader :current_piece_x, :current_piece_y, :current_piece

  def tick
    iterate unless game_over?
    render_game_over_label if game_over?
    reset_game
    render
    nil
  end

  def reset_game
    return unless keyboard.key_down.r
    start_game
  end

  attr_accessor :grid

  private

  attr_reader :keyboard, :controller_one
  attr_writer :current_piece,
              :current_piece_x, :current_piece_y
  attr_accessor :ended, :score, :future_piece, :tick_rate, :next_move


  def iterate
    move_left
    move_right
    move_down
    rotate_left
    rotate_right

    self.next_move -= 1
    return unless next_move <= 0

    if collision_detected?
      plant_current_piece
      reset_position_for_next_piece
      increase_score_and_speed
      set_next_piece
      set_future_piece
      game_over!
    else
      move_current_piece_down
    end
    reset_tick_rate
  end

  def game_over!
    return unless space_already_occupied?
    self.ended = true
  end

  def game_over?
    ended
  end

  def render_game_over_label
    args.outputs.labels << [
      640,
      460,
      "GAME OVER",
      70,
      1,
      *COLORS[0],
    ]
  end

  def increase_score_and_speed
    return unless grid.completed_rows?

    grid.clear_completed_rows!
    self.score += grid.cleared_rows_count
    grid.reset_cleared_rows_count
    increase_speed
  end

  def increase_speed
    scaling_factor = 12
    self.tick_rate = 30 / (score/ scaling_factor + 1)
  end

  def set_next_piece
    self.current_piece = future_piece || random_piece
  end

  def set_future_piece
    self.future_piece = random_piece
  end

  def rotate_left
    return unless rotate_left_detected?

    current_piece.rotate_left

    if grid.out_of_right_bound?(piece: current_piece, x: current_piece_x)
      correct_current_piece_x_after_rotation
    end

    if grid.already_occupied?(piece: current_piece, x: current_piece_x, y: current_piece_y)
      current_piece.rotate_right
      return
    end
  end

  def rotate_right
    return unless rotate_right_detected?

    current_piece.rotate_right

    if grid.out_of_right_bound?(piece: current_piece, x: current_piece_x)
      correct_current_piece_x_after_rotation
    end

    if grid.already_occupied?(piece: current_piece, x: current_piece_x, y: current_piece_y)
      current_piece.rotate_left
      return
    end

  end

  def correct_current_piece_x_after_rotation
    self.current_piece_x = current_piece_x - current_piece.width + 1
  end

  def rotate_left_detected?
    keyboard.key_down.a || controller_one.a
  end

  def rotate_right_detected?
    keyboard.key_down.s || controller_one.b
  end

  def reset_position_for_next_piece
    self.current_piece_x = 5
    self.current_piece_y = 0
  end

  def move_left
    return unless left_movement_detected?
    return if piece_detected_left?
    return if out_of_left_bound?

    self.current_piece_x -= 1
  end

  def left_movement_detected?
    keyboard.key_down.left || controller_one.key_down.left
  end

  def piece_detected_left?
    grid.already_occupied?(x: current_piece_x - 1, y: current_piece_y, piece: current_piece)
  end

  def move_right
    return unless right_movement_detected?
    return if out_of_right_bounds?
    return if piece_detected_right?

    self.current_piece_x += 1
  end

  def right_movement_detected?
    keyboard.key_down.right || controller_one.key_down.right
  end

  def piece_detected_right?
    grid.already_occupied?(x: current_piece_x + 1, y: current_piece_y, piece: current_piece)
  end

  def out_of_left_bound?
    attempted_x = current_piece_x - 1
    grid.out_of_left_bound?(attempted_x)
  end

  def out_of_right_bounds?
    attempted_x = current_piece_x + 1
    grid.out_of_right_bound?(x: attempted_x, piece: current_piece)
  end

  def move_down
    return if collision_detected?
    return unless down_movement_detected?

    self.current_piece_y += 1
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
    render_future_piece
    render_score
    # debug
  end

  def debug
    args.outputs.labels << [
      200,
      700,
      "Tick rate: #{tick_rate}",
      1,
      1,
      *COLORS[0],
    ]
  end

  def render_score
    args.outputs.labels << [
      200, # X
      200, # Y
      "Score: #{score}", # TEXT
      20, # SIZE_ENUM
      1, # ALIGNMENT_ENUM
      *COLORS[0],
    ]
  end

  def random_piece
    Piece.random
  end

  def plant_current_piece
    grid.plant_piece(x: current_piece_x, y: current_piece_y, piece: current_piece)
  end

  def collision_detected?
    current_piece_reached_bottom? || space_already_occupied?
  end

  def space_already_occupied?
    grid.already_occupied?(x: current_piece_x, y: current_piece_y + 1, piece: current_piece)
  end

  def current_piece_reached_bottom?
    grid.reached_bottom?(piece: current_piece, y: current_piece_y)
  end

  def move_current_piece_down
    self.current_piece_y += 1
  end

  def reset_tick_rate
    self.next_move = tick_rate
  end

  def render_current_piece
    current_piece.matrix.each_with_index do |column, column_i|
      column.each_with_index do |value, row_i|
        next if current_piece.matrix[column_i][row_i].zero?

        render_cube(current_piece_x + column_i, current_piece_y + row_i, color: value)
      end
    end
  end

  def render_future_piece
    future_piece.matrix.each_with_index do |column, column_i|
      column.each_with_index do |value, row_i|
        next if future_piece.matrix[column_i][row_i].zero?

        render_cube(GRID_COLUMNS + 6 + column_i, 2 + row_i, color: value)
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
    args.outputs.solids << [0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, [0, 0, 0]]
    render_grid_border
    render_future_piece_border
  end

  def render_future_piece_border
    6.times do |i|
      render_cube(GRID_COLUMNS + 4 + i, 0, color: 8)
      render_cube(GRID_COLUMNS + 4 + i, 6, color: 8)
    end

    7.times do |i|
      render_cube(GRID_COLUMNS + 4, i, color: 8)
      render_cube(GRID_COLUMNS + 4 + 6, i, color: 8)
    end
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
    args.outputs.solids << [cube_x, cube_y, CUBE_SIZE, CUBE_SIZE, *COLORS[color]]
    args.outputs.borders << [cube_x, cube_y, CUBE_SIZE, CUBE_SIZE, *COLORS[0]]
  end

end