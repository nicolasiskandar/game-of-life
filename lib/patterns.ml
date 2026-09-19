let seed_pattern g origin_row origin_col offsets =
  List.fold_left
    (fun g (dr, dc) -> Grid.set g (origin_row + dr) (origin_col + dc) Cell.Alive)
    g
    offsets

let glider = [ (0, 1); (1, 2); (2, 0); (2, 1); (2, 2) ]
let blinker = [ (0, 0); (0, 1); (0, 2) ]
let block = [ (0, 0); (0, 1); (1, 0); (1, 1) ]