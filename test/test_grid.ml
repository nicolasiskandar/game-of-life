open OUnit2
open Game_of_life

let test_make_grid_dimensions _ =
  let g = Grid.make_grid 5 7 in
  assert_equal 5 g.width;
  assert_equal 7 g.height

let test_make_grid_starts_dead _ =
  let g = Grid.make_grid 3 3 in
  assert_equal Cell.Dead (Grid.get g 1 1)

let test_set_get_roundtrip _ =
  let g = Grid.make_grid 4 4 in
  let g = Grid.set g 2 3 Cell.Alive in
  assert_equal Cell.Alive (Grid.get g 2 3);
  assert_equal Cell.Dead (Grid.get g 2 2)

let suite = "grid" >::: [
  "make_grid sets dimensions" >:: test_make_grid_dimensions;
  "make_grid starts all dead" >:: test_make_grid_starts_dead;
  "set/get roundtrip" >:: test_set_get_roundtrip;
]