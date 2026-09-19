val offsets : (int * int) list

val neighbors : int -> int -> (int * int) list

val fold_neighbors : ('a -> int * int -> 'a) -> 'a -> int -> int -> 'a