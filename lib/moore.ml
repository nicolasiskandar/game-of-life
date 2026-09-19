let offsets =
  [ (-1, -1); (-1, 0); (-1, 1);
    (0, -1);           (0, 1);
    (1, -1);  (1, 0);  (1, 1) ]

let neighbors row col =
  List.map (fun (dr, dc) -> (row + dr, col + dc)) offsets

let fold_neighbors f acc row col =
  List.fold_left
    (fun acc (dr, dc) -> f acc (row + dr, col + dc))
    acc
    offsets