type grid = {
  width : int;
  height : int;
  cells : Cell.cell_state array;
}

val index : grid -> int -> int -> int
val make_grid : int -> int -> grid
val get : grid -> int -> int -> Cell.cell_state
val set : grid -> int -> int -> Cell.cell_state -> grid