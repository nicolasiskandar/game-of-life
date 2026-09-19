let next_state current neighbor_count =
  match current, neighbor_count with
  | Cell.Alive, n when n < 2 -> Cell.Dead
  | Cell.Alive, n when n = 2 || n = 3 -> Cell.Alive
  | Cell.Alive, n when n > 3 -> Cell.Dead
  | Cell.Dead, n when n = 3 -> Cell.Alive
  | _, _ -> Cell.Dead