module Coord = struct
  type t = int * int
  let compare = compare
end

module CoordSet = Set.Make(Coord)

type sparse_grid = CoordSet.t

let life_state live (row, col) =
  if CoordSet.mem (row, col) live then Cell.Alive else Cell.Dead

let live_neighbor_count live (row, col) =
  Moore.fold_neighbors
    (fun acc (r, c) -> if CoordSet.mem (r, c) live then acc + 1 else acc)
    0
    row
    col

let survives live cell =
  Rules.next_state (life_state live cell) (live_neighbor_count live cell)
  = Cell.Alive

let sparse_step (live : sparse_grid) : sparse_grid =
  let candidates =
    CoordSet.fold
      (fun cell acc ->
         List.fold_left
           (fun acc n -> CoordSet.add n acc)
           acc
           (cell :: Moore.neighbors (fst cell) (snd cell)))
      live
      CoordSet.empty
  in
  CoordSet.filter (survives live) candidates