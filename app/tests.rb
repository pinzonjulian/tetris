# Run the tests: ./dragonruby mygame --eval app/tests.rb --no-tick


# def test_grid_is_initialized_properly(args, assert)
#   grid = Grid.new(width: 10, height: 20)
#
#   assert.true!(grid.grid.size == 10)
#   assert.true!(grid.grid.first.size == 20)
#   assert.true!(grid.grid.flatten.uniq.size == 1)
# end
#
# def test_plant_piece(args, assert)
#   grid = Grid.new(width: 10, height: 20)
#   piece = [ [1, 1], [1, 1] ]
#   grid.plant_piece(x: 8, y: 18, piece: piece)
#   expected = [
#     grid.grid[8][18], grid.grid[8][19],
#     grid.grid[9][18], grid.grid[9][19]
#   ]
#   assert.true! expected.all?(1)
# end
#
# def test_error_when_overflowing_x(args, assert)
#   grid = Grid.new(width: 10, height: 20)
#   piece = [ [1, 1], [1, 1] ]
#   grid.plant_piece(x: 10, y: 1, piece: piece)
#   assert.false! "Should have raised an exception"
# rescue Grid::OverflowXError => exception
#   assert.true! exception
# end
#
# def test_error_when_overflowing_y(args, assert)
#   grid = Grid.new(width: 10, height: 20)
#   piece = [ [1, 1], [1, 1] ]
#   grid.plant_piece(x: 2, y: 20, piece: piece)
#   assert.false! "Should have raised an exception"
# rescue Grid::OverflowYError => exception
#   assert.true! exception
# end

def test_checks_if_occupied(args,assert)
  grid = Grid.new(width: 10, height: 20)
  piece = [[1,1], [1,1]]
  grid.plant_piece(x: 0, y: 18, piece: piece)

  new_piece = [[1,1], [1,1]]
  assert.true! grid.already_occupied?(x: 1, y: 17, piece: new_piece)
  assert.false! grid.already_occupied?(x: 5, y: 17, piece: new_piece)

  # when the piece is irregular
  irregular_piece = [[0, 1], [1, 1], [1, 0]]
end

puts "running tests"
$gtk.reset 100
$gtk.tests.start