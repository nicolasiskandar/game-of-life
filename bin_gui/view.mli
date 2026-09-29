
type color = { r : int; g : int; b : int }

type theme = {
  background : color;
  alive : color;
  cell_size : int;
  cell_inset : int;
}

val max_window_size : int * int
val window_title : string
val dark_theme : theme
val default_theme : theme
val init : width:int -> height:int -> title:string -> unit

type layout = {
  width : int;
  height : int;
  pitch : int;
  origin_x : int;
  origin_y : int;
}

val cell_bounds : theme -> int -> int -> int * int * int * int
val cell_rect : layout -> int -> int -> int * int * int * int
val cell_body : theme -> int -> int -> int * int
val layout : Game_of_life.Grid.grid -> theme -> layout
val draw_grid : theme -> Game_of_life.Grid.grid -> unit

type command = Next | Previous | Quit | Stay
val poll_command : unit -> command
val frame_delay : float
val generations_per_pattern : int
val wrap_index : int -> int -> int
val reseed : Game_of_life.Grid.grid -> (int * int) list -> Game_of_life.Grid.grid
val step : Game_of_life.Grid.grid -> Game_of_life.Grid.grid
val animate : theme -> Game_of_life.Grid.grid -> catalog:(string * (int * int) list) list -> unit
