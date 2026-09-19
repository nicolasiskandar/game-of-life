open OUnit2
open Game_of_life

let test_parse_glider_body _ =
  let offsets = Rle.parse_rle_body "bob$2bo$3o!" in
  assert_equal
    (List.sort compare Patterns.glider)
    (List.sort compare offsets)

let test_parse_blinker_body _ =
  let offsets = Rle.parse_rle_body "3o!" in
  assert_equal
    (List.sort compare Patterns.blinker)
    (List.sort compare offsets)

let test_parse_block_body _ =
  let offsets = Rle.parse_rle_body "2o$2o!" in
  assert_equal
    (List.sort compare Patterns.block)
    (List.sort compare offsets)

let suite = "rle" >::: [
  "parses glider body" >:: test_parse_glider_body;
  "parses blinker body" >:: test_parse_blinker_body;
  "parses block body" >:: test_parse_block_body;
]