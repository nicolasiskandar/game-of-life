type config = {
  width : int;
  height : int;
  generations : int;
  pattern : string option;
}

let default_config = { width = 20; height = 10; generations = 100; pattern = None }

let parse () =
  let width = ref default_config.width in
  let height = ref default_config.height in
  let generations = ref default_config.generations in
  let pattern_file = ref None in
  let speclist = [
    ("--width", Arg.Set_int width, "Grid width (default 20)");
    ("--height", Arg.Set_int height, "Grid height (default 10)");
    ("--generations", Arg.Set_int generations, "Number of generations (default 100)");
    ("--pattern", Arg.String (fun s -> pattern_file := Some s), "Path to an RLE pattern file");
  ]
  in
  Arg.parse speclist (fun _ -> ()) "game_of_life [options]";
  { width = !width; height = !height; generations = !generations; pattern = !pattern_file }