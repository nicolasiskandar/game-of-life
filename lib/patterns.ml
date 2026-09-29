open Grid

let seed_pattern g origin_row origin_col offsets =
  List.fold_left
    (fun g (dr, dc) -> Grid.set g (origin_row + dr) (origin_col + dc) Cell.Alive)
    g
    offsets

let size offsets =
  List.fold_left
    (fun (height, width) (dr, dc) ->
      (max height (dr + 1), max width (dc + 1)))
    (0, 0)
    offsets

let seed_centered g offsets =
  let height, width = size offsets in
  let origin_row = (g.height - height) / 2 in
  let origin_col = (g.width - width) / 2 in
  List.fold_left
    (fun g (dr, dc) ->
      let row = origin_row + dr in
      let col = origin_col + dc in
      if row >= 0 && row < g.height && col >= 0 && col < g.width then
        Grid.set g row col Cell.Alive
      else g)
    g
    offsets

let glider = [ (0, 1); (1, 2); (2, 0); (2, 1); (2, 2) ]
let blinker = [ (0, 0); (0, 1); (0, 2) ]
let block = [ (0, 0); (0, 1); (1, 0); (1, 1) ]

let beehive = [ (0, 1); (0, 2); (1, 0); (1, 3); (2, 1); (2, 2) ]

let boat = [ (0, 0); (0, 1); (1, 0); (1, 2); (2, 1) ]

let loaf = [ (0, 1); (0, 2); (1, 0); (1, 3); (2, 1); (2, 3); (3, 2) ]

let toad = [ (0, 1); (0, 2); (0, 3); (1, 0); (1, 1); (1, 2) ]

let beacon =
  [ (0, 0); (0, 1); (1, 0); (1, 1); (2, 2); (2, 3); (3, 2); (3, 3) ]

let pulsar =
  [ (0, 2); (0, 3); (0, 4); (0, 8); (0, 9); (0, 10);
    (2, 0); (2, 5); (2, 7); (2, 12);
    (3, 0); (3, 5); (3, 7); (3, 12);
    (4, 0); (4, 5); (4, 7); (4, 12);
    (5, 2); (5, 3); (5, 4); (5, 8); (5, 9); (5, 10);
    (7, 2); (7, 3); (7, 4); (7, 8); (7, 9); (7, 10);
    (8, 0); (8, 5); (8, 7); (8, 12);
    (9, 0); (9, 5); (9, 7); (9, 12);
    (10, 0); (10, 5); (10, 7); (10, 12);
    (12, 2); (12, 3); (12, 4); (12, 8); (12, 9); (12, 10) ]

let pentadecathlon =
  [ (0, 2); (0, 7);
    (1, 0); (1, 1); (1, 3); (1, 4); (1, 5); (1, 6); (1, 8); (1, 9);
    (2, 2); (2, 7) ]

let lwss =
  [ (0, 1); (0, 4); (1, 0); (2, 0); (2, 4); (3, 0); (3, 1); (3, 2); (3, 3) ]

let r_pentomino = [ (0, 1); (0, 2); (1, 0); (1, 1); (2, 1) ]

let diehard = [ (0, 6); (1, 0); (1, 1); (2, 1); (2, 5); (2, 6); (2, 7) ]

let acorn = [ (0, 1); (1, 3); (2, 0); (2, 1); (2, 4); (2, 5); (2, 6) ]

let gosper_gun =
  [ (0, 24);
    (1, 22); (1, 24);
    (2, 12); (2, 13); (2, 20); (2, 21); (2, 34); (2, 35);
    (3, 11); (3, 15); (3, 20); (3, 21); (3, 34); (3, 35);
    (4, 0); (4, 1); (4, 10); (4, 16); (4, 20); (4, 21);
    (5, 0); (5, 1); (5, 10); (5, 14); (5, 16); (5, 17); (5, 22); (5, 24);
    (6, 10); (6, 16); (6, 24);
    (7, 11); (7, 15);
    (8, 12); (8, 13) ]

let catalog =
  [ ("block", block);
    ("beehive", beehive);
    ("boat", boat);
    ("loaf", loaf);
    ("blinker", blinker);
    ("toad", toad);
    ("beacon", beacon);
    ("pulsar", pulsar);
    ("pentadecathlon", pentadecathlon);
    ("glider", glider);
    ("lwss", lwss);
    ("r_pentomino", r_pentomino);
    ("acorn", acorn);
    ("diehard", diehard);
    ("gosper_gun", gosper_gun) ]
