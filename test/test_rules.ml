open OUnit2
open Game_of_life

let test_dies_underpopulation _ =
  assert_equal Cell.Dead (Rules.next_state Cell.Alive 0);
  assert_equal Cell.Dead (Rules.next_state Cell.Alive 1)

let test_survives_two_or_three _ =
  assert_equal Cell.Alive (Rules.next_state Cell.Alive 2);
  assert_equal Cell.Alive (Rules.next_state Cell.Alive 3)

let test_dies_overpopulation _ =
  assert_equal Cell.Dead (Rules.next_state Cell.Alive 4)

let test_reproduction _ =
  assert_equal Cell.Alive (Rules.next_state Cell.Dead 3)

let test_stays_dead _ =
  assert_equal Cell.Dead (Rules.next_state Cell.Dead 0);
  assert_equal Cell.Dead (Rules.next_state Cell.Dead 1);
  assert_equal Cell.Dead (Rules.next_state Cell.Dead 2);
  assert_equal Cell.Dead (Rules.next_state Cell.Dead 4)

let suite = "rules" >::: [
  "live cell dies with fewer than 2 neighbors" >:: test_dies_underpopulation;
  "live cell survives with 2 or 3 neighbors" >:: test_survives_two_or_three;
  "live cell dies with more than 3 neighbors" >:: test_dies_overpopulation;
  "dead cell is born with exactly 3 neighbors" >:: test_reproduction;
  "dead cell stays dead otherwise" >:: test_stays_dead;
]