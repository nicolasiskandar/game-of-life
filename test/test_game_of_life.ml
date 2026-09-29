open OUnit2

let all =
  "game_of_life" >::: [
    Test_grid.suite;
    Test_rules.suite;
    Test_simulation.suite;
    Test_rle.suite;
    Test_sparse.suite;
    Test_patterns.suite;
  ]

let () = run_test_tt_main all