open Game_of_life

let width = 48
let height = 30

let () =
  let g = Grid.make_grid width height in
  let cell = View.dark_theme.cell_size in
  View.init ~width:(width * cell) ~height:(height * cell) ~title:View.window_title;
  View.animate View.dark_theme g ~catalog:Patterns.catalog
