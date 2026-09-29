open OUnit2
open Game_of_life
open Grid

let live_cells g =
  let acc = ref [] in
  for row = 0 to g.height - 1 do
    for col = 0 to g.width - 1 do
      if Cell.is_alive (Grid.get g row col) then acc := (row, col) :: !acc
    done
  done;
  List.rev !acc

let normalize cells =
  match cells with
  | [] -> []
  | _ ->
    let min_row = List.fold_left (fun acc (r, _) -> min acc r) max_int cells in
    let min_col = List.fold_left (fun acc (_, c) -> min acc c) max_int cells in
    List.sort compare (List.map (fun (r, c) -> (r - min_row, c - min_col)) cells)

let anchor cells =
  match cells with
  | [] -> (0, 0)
  | _ ->
    (List.fold_left (fun acc (r, _) -> min acc r) max_int cells,
     List.fold_left (fun acc (_, c) -> min acc c) max_int cells)

let population g = List.length (live_cells g)

let board w h offsets = Patterns.seed_pattern (Grid.make_grid w h) 2 2 offsets

let run g n = Simulation.run_generations g n

let assert_still_life name offsets =
  let g = board 20 20 offsets in
  let g1 = run g 1 in
  assert_equal ~msg:(name ^ " is not a still life") g.cells g1.cells

let assert_period name offsets n =
  let g = board 24 24 offsets in
  assert_equal ~msg:(name ^ " is not periodic") g.cells (run g n).cells

let assert_spaceship name offsets n row_drift col_drift =
  let g = board 30 30 offsets in
  let g_n = run g n in
  let before = live_cells g in
  let after = live_cells g_n in
  assert_equal ~msg:(name ^ " changed shape") (normalize before) (normalize after);
  let row0, col0 = anchor before in
  let row1, col1 = anchor after in
  assert_equal ~msg:(name ^ " row drift") row_drift (row1 - row0);
  assert_equal ~msg:(name ^ " col drift") col_drift (col1 - col0)

let test_still_lifes _ =
  List.iter (fun (n, p) -> assert_still_life n p)
    [ ("block", Patterns.block);
      ("beehive", Patterns.beehive);
      ("boat", Patterns.boat);
      ("loaf", Patterns.loaf) ]

let test_period_two_oscillators _ =
  List.iter (fun (n, p) -> assert_period n p 2)
    [ ("blinker", Patterns.blinker);
      ("toad", Patterns.toad);
      ("beacon", Patterns.beacon) ]

let test_pulsar_has_period_three _ =
  assert_period "pulsar" Patterns.pulsar 3

let test_pentadecathlon_has_period_fifteen _ =
  assert_period "pentadecathlon" Patterns.pentadecathlon 15

let test_glider_translates_diagonally _ =
  assert_spaceship "glider" Patterns.glider 4 1 1

let test_lwss_translates_sideways _ =
  assert_spaceship "lwss" Patterns.lwss 4 0 (-2)

let test_diehard_dies_out _ =
  let g = board 60 60 Patterns.diehard in
  assert_bool "diehard vanished too early" (population (run g 129) > 0);
  assert_equal ~msg:"diehard should die at generation 130" 0 (population (run g 130))

let test_r_pentomino_outlives_a_hundred_generations _ =
  let g = board 120 120 Patterns.r_pentomino in
  let g100 = run g 100 in
  assert_bool "r-pentomino should still be alive" (population g100 > 0)

let test_size_reports_the_bounding_box _ =
  assert_equal (3, 3) (Patterns.size Patterns.glider);
  assert_equal (1, 3) (Patterns.size Patterns.blinker);
  assert_equal (2, 2) (Patterns.size Patterns.block);
  assert_equal (9, 36) (Patterns.size Patterns.gosper_gun);
  assert_equal (13, 13) (Patterns.size Patterns.pulsar);
  assert_equal (0, 0) (Patterns.size [])

let test_every_catalog_pattern_fits_the_board _ =
  List.iter
    (fun (name, offsets) ->
      let height, width = Patterns.size offsets in
      assert_bool
        (Printf.sprintf "%s is %dx%d, too large for a 48x30 board" name height width)
        (height <= 30 && width <= 48))
    Patterns.catalog

let test_catalog_entries_match_the_named_patterns _ =
  let named =
    [ ("block", Patterns.block);
      ("beehive", Patterns.beehive);
      ("boat", Patterns.boat);
      ("loaf", Patterns.loaf);
      ("blinker", Patterns.blinker);
      ("toad", Patterns.toad);
      ("beacon", Patterns.beacon);
      ("pulsar", Patterns.pulsar);
      ("pentadecathlon", Patterns.pentadecathlon);
      ("glider", Patterns.glider);
      ("lwss", Patterns.lwss);
      ("r_pentomino", Patterns.r_pentomino);
      ("acorn", Patterns.acorn);
      ("diehard", Patterns.diehard);
      ("gosper_gun", Patterns.gosper_gun) ]
  in
  assert_equal ~msg:"catalog contents" named Patterns.catalog

let test_seed_centered_places_a_pattern_in_the_middle _ =
  let g = Patterns.seed_centered (Grid.make_grid 20 20) Patterns.glider in
  assert_equal
    ~msg:"glider should be centered on a 20x20 grid"
    (normalize (live_cells (board 20 20 Patterns.glider)))
    (normalize (live_cells g))

let test_seed_centered_drops_cells_that_do_not_fit _ =
  let full = List.length Patterns.gosper_gun in
  let g = Patterns.seed_centered (Grid.make_grid 4 4) Patterns.gosper_gun in
  assert_bool "no cell may be written outside a 4x4 grid"
    (List.for_all (fun (r, c) -> r >= 0 && r < 4 && c >= 0 && c < 4) (live_cells g));
  assert_bool
    (Printf.sprintf "expected the 36x9 gun to be clipped, kept all %d cells" full)
    (population g < full)

let test_seed_centered_on_the_empty_pattern _ =
  let g = Patterns.seed_centered (Grid.make_grid 6 6) [] in
  assert_equal ~msg:"empty pattern" 0 (population g)

let suite = "patterns" >::: [
  "still lifes are fixpoints" >:: test_still_lifes;
  "blinker, toad, and beacon have period two" >:: test_period_two_oscillators;
  "pulsar has period three" >:: test_pulsar_has_period_three;
  "pentadecathlon has period fifteen" >:: test_pentadecathlon_has_period_fifteen;
  "glider returns to its shape shifted one cell diagonally" >:: test_glider_translates_diagonally;
  "lwss returns to its shape shifted two cells sideways" >:: test_lwss_translates_sideways;
  "diehard dies out at generation 130" >:: test_diehard_dies_out;
  "r-pentomino is still alive after 100 generations" >:: test_r_pentomino_outlives_a_hundred_generations;
  "size reports the bounding box" >:: test_size_reports_the_bounding_box;
  "every catalog pattern fits a 48x30 board" >:: test_every_catalog_pattern_fits_the_board;
  "catalog entries match the named patterns" >:: test_catalog_entries_match_the_named_patterns;
  "seed_centered centers a pattern" >:: test_seed_centered_places_a_pattern_in_the_middle;
  "seed_centered drops cells that do not fit" >:: test_seed_centered_drops_cells_that_do_not_fit;
  "seed_centered accepts the empty pattern" >:: test_seed_centered_on_the_empty_pattern;
]
