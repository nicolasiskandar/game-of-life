open Grid

let count_live_neighbors g row col =
  Moore.fold_neighbors
    (fun acc (r, c) ->
       let r = Boundary.wrap r g.height in
       let c = Boundary.wrap c g.width in
       if Cell.is_alive (Grid.get g r c) then acc + 1 else acc)
    0
    row
    col