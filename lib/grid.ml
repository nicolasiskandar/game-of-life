type grid = {
  width : int;
  height : int;
  cells : Cell.cell_state array;
}

let index (g : grid) row col = row * g.width + col

let make_grid width height =
  { width; height; cells = Array.make (width * height) Cell.Dead }

let get g row col = g.cells.(index g row col)

let set g row col state =
  let new_cells = Array.copy g.cells in
  new_cells.(index g row col) <- state;
  { g with cells = new_cells }