let parse_rle_body s =
  let len = String.length s in
  let rec go i row col count offsets =
    if i >= len then offsets
    else
      match s.[i] with
      | '0'..'9' as d ->
        let digit = Char.code d - Char.code '0' in
        let new_count =
          match count with
          | None -> digit
          | Some c -> c * 10 + digit
        in
        go (i + 1) row col (Some new_count) offsets
      | 'o' ->
        let n = Option.value count ~default:1 in
        let rec place k col acc =
          if k = 0 then (acc, col)
          else place (k - 1) (col + 1) ((row, col) :: acc)
        in
        let new_offsets, new_col = place n col offsets in
        go (i + 1) row new_col None new_offsets
      | 'b' ->
        let n = Option.value count ~default:1 in
        go (i + 1) row (col + n) None offsets
      | '$' ->
        let n = Option.value count ~default:1 in
        go (i + 1) (row + n) 0 None offsets
      | '!' -> offsets
      | _ -> go (i + 1) row col count offsets
  in
  go 0 0 0 None []

let load_file path =
  let ic = open_in path in
  let text = really_input_string ic (in_channel_length ic) in
  close_in ic;
  text
  |> String.split_on_char '\n'
  |> List.filter (fun line ->
       let l = String.trim line in
       l <> ""
       && not (String.starts_with ~prefix:"x =" l)
       && not (String.starts_with ~prefix:"#" l))
  |> String.concat "\n"
  |> parse_rle_body