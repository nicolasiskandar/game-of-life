let clear_screen () =
  print_string "\027[H\027[2J";
  flush stdout

let rec animate options g n =
  if n = 0 then ()
  else begin
    clear_screen ();
    print_string (Render.render options g);
    flush stdout;
    Unix.sleepf 0.2;
    animate options (Simulation.step g) (n - 1)
  end