type render_options = { alive_char : char; dead_char : char }

open Grid

let default_options = { alive_char = '#'; dead_char = '.' }

let render options g =
  let buf = Buffer.create (g.width * g.height + g.height) in
  for row = 0 to g.height - 1 do
    for col = 0 to g.width - 1 do
      let ch =
        match Grid.get g row col with
        | Cell.Alive -> options.alive_char
        | Cell.Dead -> options.dead_char
      in
      Buffer.add_char buf ch
    done;
    Buffer.add_char buf '\n'
  done;
  Buffer.contents buf