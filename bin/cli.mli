type config = {
  width : int;
  height : int;
  generations : int;
  pattern : string option;
}

val default_config : config
val parse : unit -> config