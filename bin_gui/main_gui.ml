open Game_of_life

let () =
  View.init ();
  let g = Grid.make_grid 40 30 in
  let g = Patterns.seed_pattern g 5 5 Patterns.glider in
  View.animate_gui g 300