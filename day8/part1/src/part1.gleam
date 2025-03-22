import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import simplifile as sf

type Coords =
  #(Int, Int)

type Freqs =
  Dict(String, List(Coords))

type Antinodes =
  Set(Coords)

pub fn main() {
  io.println("Hello from part1!")
  let assert Ok(lines) = sf.read("../input")
  io.println(lines)
  let freqs: Freqs = populate_freqs(#(0, 0), dict.new(), lines)
  echo freqs
  let antinodes: Antinodes = compute_antinodes(freqs)
  echo antinodes
  echo set.size(antinodes)
}

fn populate_freqs(curr: Coords, freqs: Freqs, lines: String) -> Freqs {
  case string.pop_grapheme(lines) {
    Error(_) -> freqs
    Ok(#(antenna, tail)) ->
      case antenna {
        "\n" -> populate_freqs(#(curr.0 + 1, 0), freqs, tail)
        "." -> populate_freqs(#(curr.0, curr.1 + 1), freqs, tail)
        _ ->
          case dict.get(freqs, antenna) {
            Error(Nil) -> {
              let freqs = dict.insert(freqs, antenna, [curr])
              populate_freqs(#(curr.0, curr.1 + 1), freqs, tail)
            }
            Ok(coords) -> {
              let freqs = dict.insert(freqs, antenna, [curr, ..coords])
              populate_freqs(#(curr.0, curr.1 + 1), freqs, tail)
            }
          }
      }
  }
}

//............
//...#....0...
//.....0...... <- (2, 5)
//.......0.... <- (3, 7) Antinodes at (1, 3) and (4, 9)
//....0....#..
//......A.....
//............
//............
//........A...
//.........A..
//............
//............

fn valid_coords(coords: Coords) -> Bool {
  coords.0 >= 0 && coords.0 < 50 && coords.1 >= 0 && coords.1 < 50
}

fn check_coord_pair(a: Coords, b: Coords) -> Set(Coords) {
  let x_d = a.1 - b.1
  let y_d = a.0 - b.0
  let an1 = #(a.0 + y_d, a.1 + x_d)
  let an2 = #(b.0 - y_d, b.1 - x_d)

  set.new()
  |> set.insert(an1)
  |> set.insert(an2)
  |> set.filter(valid_coords)
}

fn head_rest_list(
  coords: List(Coords),
  result: List(#(Coords, List(Coords))),
) -> List(#(Coords, List(Coords))) {
  case coords {
    [head, ..rest] if rest != [] -> {
      let result = [#(head, rest), ..result]
      head_rest_list(rest, result)
    }
    _ -> result
  }
}

fn compute_antinodes(freqs: Freqs) -> Antinodes {
  freqs
  |> dict.to_list()
  |> list.map(fn(a) {
    let #(_, coords) = a
    let subj = process.new_subject()
    process.start(fn() { check_coord_list(coords, subj) }, True)
    subj
  })
  |> list.map(process.receive_forever)
  |> list.fold(set.new(), fn(a: Antinodes, n: Antinodes) { set.union(a, n) })
}

fn check_coord_list(coords: List(Coords), superv: process.Subject(Set(Coords))) {
  coords
  |> head_rest_list([])
  |> list.map(fn(hr) {
    let #(head, rest) = hr
    let subj = process.new_subject()
    process.start(fn() { check_coord_pairs(head, rest, subj) }, True)
    subj
  })
  |> list.map(process.receive_forever)
  |> list.fold(set.new(), fn(a: Antinodes, n: Antinodes) { set.union(a, n) })
  |> process.send(superv, _)
}

fn check_coord_pairs(
  first: Coords,
  rest: List(Coords),
  superv: process.Subject(Set(Coords)),
) {
  rest
  |> list.map(fn(curr) { check_coord_pair(first, curr) })
  |> list.fold(set.new(), fn(a: Antinodes, n: Antinodes) { set.union(a, n) })
  |> process.send(superv, _)
}

