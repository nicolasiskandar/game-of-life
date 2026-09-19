open Game_of_life

val cell_size : int
val init : unit -> unit
val draw_grid : Grid.grid -> unit
val animate_gui : Grid.grid -> int -> unit