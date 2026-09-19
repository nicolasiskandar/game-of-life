open Game_of_life
open Grid

let cell_size = 10

let init () =
  Graphics.open_graph " ";
  Graphics.auto_synchronize false

let draw_grid g =
  Graphics.clear_graph ();
  for row = 0 to g.height - 1 do
    for col = 0 to g.width - 1 do
      (match Grid.get g row col with
       | Cell.Alive -> Graphics.set_color Graphics.black
       | Cell.Dead -> Graphics.set_color Graphics.white);
      Graphics.fill_rect (col * cell_size) (row * cell_size) cell_size cell_size
    done
  done

let rec animate_gui g n =
  if n = 0 then ()
  else begin
    draw_grid g;
    Graphics.synchronize ();
    Unix.sleepf 0.1;
    animate_gui (Simulation.step g) (n - 1)
  end