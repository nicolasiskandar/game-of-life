open Grid

let step g =
  let width = g.width in
  let height = g.height in
  let cells =
    Array.init (width * height) (fun i ->
      let row = i / width in
      let col = i mod width in
      Rules.next_state
        (Grid.get g row col)
        (Neighborhood.count_live_neighbors g row col))
  in
  { g with cells }

let rec run_generations g n =
  if n = 0 then g else run_generations (step g) (n - 1)