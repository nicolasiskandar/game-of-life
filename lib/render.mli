type render_options = { alive_char : char; dead_char : char }

val default_options : render_options
val render : render_options -> Grid.grid -> string