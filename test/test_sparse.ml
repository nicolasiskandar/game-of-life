open OUnit2
open Game_of_life
open Grid

let cells_of_grid g =
  let acc = ref Sparse.CoordSet.empty in
  for row = 0 to g.height - 1 do
    for col = 0 to g.width - 1 do
      if Cell.is_alive (Grid.get g row col) then
        acc := Sparse.CoordSet.add (row, col) !acc
    done
  done;
  !acc

let grid_of_cells width height cells =
  Sparse.CoordSet.fold
    (fun (row, col) g -> Grid.set g row col Cell.Alive)
    cells
    (Grid.make_grid width height)

let test_sparse_matches_dense_block _ =
  let g = Patterns.seed_pattern (Grid.make_grid 5 5) 1 1 Patterns.block in
  let dense = Simulation.step g in
  let sparse = Sparse.sparse_step (cells_of_grid g) in
  assert_equal dense.cells (grid_of_cells 5 5 sparse).cells

let test_sparse_matches_dense_glider _ =
  let g = Patterns.seed_pattern (Grid.make_grid 10 10) 1 1 Patterns.glider in
  let dense = Simulation.step g in
  let sparse = Sparse.sparse_step (cells_of_grid g) in
  assert_equal dense.cells (grid_of_cells 10 10 sparse).cells

let suite = "sparse" >::: [
  "sparse_step matches dense step for block" >:: test_sparse_matches_dense_block;
  "sparse_step matches dense step for glider" >:: test_sparse_matches_dense_glider;
]