module Coord : sig
  type t = int * int
  val compare : t -> t -> int
end

module CoordSet : Set.S with type elt = Coord.t

type sparse_grid = CoordSet.t

val sparse_step : sparse_grid -> sparse_grid