open Game_of_life
open Grid

type color = { r : int; g : int; b : int }

type theme = {
  background : color;
  alive : color;
  cell_size : int;
  cell_inset : int;
}

let max_window_size = (1024, 640)
let window_title = "Game of Life"
let dark_theme =
  { background = { r = 13; g = 17; b = 23 };
    alive = { r = 57; g = 255; b = 20 };
    cell_size = 20;
    cell_inset = 1 }

let default_theme = dark_theme

let init ~width ~height ~title =
  Graphics.open_graph (Printf.sprintf " %dx%d" width height);
  Graphics.set_window_title title;
  Graphics.auto_synchronize false

type layout = {
  width : int;
  height : int;
  pitch : int;
  origin_x : int;
  origin_y : int;
}

let cell_bounds theme row col =
  let pitch = theme.cell_size in
  let inset = theme.cell_inset in
  ( (col * pitch) + inset,
    (row * pitch) + inset,
    pitch - (inset * 2) - 1,
    pitch - (inset * 2) - 1 )

let cell_rect layout row col =
  let x, y, w, h = cell_bounds default_theme row col in
  (layout.origin_x + x, layout.origin_y + y, w, h)

let cell_body theme row col =
  let _, _, w, h = cell_bounds theme row col in
  (w + 1, h + 1)

let layout (g : Grid.grid) theme : layout =
  let screen_width = Graphics.size_x () in
  let screen_height = Graphics.size_y () in
  let cap_width, cap_height = max_window_size in
  let width = min (g.width * theme.cell_size) (min screen_width cap_width) in
  let height = min (g.height * theme.cell_size) (min screen_height cap_height) in
  let pitch = max 1 (min theme.cell_size (min (width / g.width) (height / g.height))) in
  let board_width = pitch * g.width in
  let board_height = pitch * g.height in
  { width; height; pitch; origin_x = (width - board_width) / 2; origin_y = (height - board_height) / 2 }

let draw_background theme ~width ~height =
  let { r; g; b } = theme.background in
  Graphics.set_color (Graphics.rgb r g b);
  Graphics.fill_rect 0 0 (width - 1) (height - 1)

let draw_alive theme ~origin_x ~origin_y row col pitch =
  let { r; g; b } = theme.alive in
  Graphics.set_color (Graphics.rgb r g b);
  let inset = theme.cell_inset in
  Graphics.fill_rect (origin_x + (col * pitch) + inset) (origin_y + (row * pitch) + inset)
    (pitch - (inset * 2)) (pitch - (inset * 2))

let draw_grid theme g =
  let l = layout g theme in
  draw_background theme ~width:l.width ~height:l.height;
  for row = 0 to g.height - 1 do
    for col = 0 to g.width - 1 do
      if Cell.is_alive (Grid.get g row col) then
        draw_alive theme ~origin_x:l.origin_x ~origin_y:l.origin_y row col l.pitch
    done
  done;
  Graphics.synchronize ()

type command = Next | Previous | Quit | Stay

let poll_command () =
  let status = Graphics.wait_next_event [ Graphics.Poll ] in
  if not status.keypressed then Stay
  else
    match Graphics.read_key () with
    | ' ' | 'n' | 'j' | 'N' | 'J' -> Next
    | 'p' | 'k' | 'P' | 'K' -> Previous
    | 'q' | 'Q' | '\027' -> Quit
    | _ -> Stay

let frame_delay = 0.05
let generations_per_pattern = 200

let wrap_index index length =
  if length <= 0 then 0
  else
    let n = index mod length in
    if n < 0 then n + length else n

let reseed blank offsets = Patterns.seed_centered blank offsets

let step g = Simulation.step g

let rec loop theme (blank : Grid.grid) catalog index (g : Grid.grid) generation =
  draw_grid theme g;
  match poll_command () with
  | Quit -> ()
  | Next -> advance theme blank catalog (index + 1)
  | Previous -> advance theme blank catalog (index - 1)
  | Stay ->
    if generation + 1 >= generations_per_pattern then
      advance theme blank catalog (index + 1)
    else begin
      Unix.sleepf frame_delay;
      loop theme blank catalog index (step g) (generation + 1)
    end

and advance theme blank catalog index =
  let length = List.length catalog in
  if length = 0 then ()
  else
    let index = wrap_index index length in
    let _, offsets = List.nth catalog index in
    loop theme blank catalog index (reseed blank offsets) 0

let animate theme (g : Grid.grid) ~catalog =
  let blank = Grid.make_grid g.width g.height in
  advance theme blank catalog 0
