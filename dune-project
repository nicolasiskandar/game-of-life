(lang dune 3.0)
(generate_opam_files true)

(package
 (name game_of_life)
 (synopsis "An OCaml implementation of Conway's Game of Life")
 (description "A terminal- and graphics-based Game of Life simulator, built as a teaching project.")
 (depends
  (ocaml (>= 4.14))
  dune
  unix
  graphics
  (ounit2 :with-test)))
