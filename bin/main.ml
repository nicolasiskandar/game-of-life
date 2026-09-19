open Game_of_life

let () =
  let cfg = Cli.parse () in
  let g = Grid.make_grid cfg.width cfg.height in
  let g =
    match cfg.pattern with
    | Some path -> Patterns.seed_pattern g 0 0 (Rle.load_file path)
    | None -> Patterns.seed_pattern g 1 1 Patterns.glider
  in
  Terminal.animate Render.default_options g cfg.generations