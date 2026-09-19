open OUnit2
open Game_of_life

let test_blinker_oscillates _ =
  let g = Grid.make_grid 5 5 in
  let g = Patterns.seed_pattern g 1 1 Patterns.blinker in
  let g3 = Simulation.step (Simulation.step g) in
  assert_equal g.cells g3.cells

let test_block_is_unchanged _ =
  let g = Grid.make_grid 5 5 in
  let g = Patterns.seed_pattern g 1 1 Patterns.block in
  let g2 = Simulation.step g in
  assert_equal g.cells g2.cells

let test_corner_wraps_correctly _ =
  let g = Grid.make_grid 3 3 in
  let g = Grid.set g 0 0 Cell.Alive in
  let g = Grid.set g 2 2 Cell.Alive in
  assert_equal 1 (Neighborhood.count_live_neighbors g 0 0)

let test_run_generations_matches_repeated_steps _ =
  let g = Grid.make_grid 5 5 in
  let g = Patterns.seed_pattern g 1 1 Patterns.blinker in
  let manual = Simulation.step (Simulation.step g) in
  let via_run = Simulation.run_generations g 2 in
  assert_equal manual.cells via_run.cells

let suite = "simulation" >::: [
  "blinker returns to start after two steps" >:: test_blinker_oscillates;
  "block still life is unchanged by step" >:: test_block_is_unchanged;
  "corner neighbor count wraps correctly" >:: test_corner_wraps_correctly;
  "run_generations matches repeated steps" >:: test_run_generations_matches_repeated_steps;
]