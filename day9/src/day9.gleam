import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/string
import glearray.{type Array}
import simplifile

pub fn main() {
  io.println("Hello from day9!")
  let assert Ok(lines) = simplifile.read("input")
  io.println(lines)

  lines
  |> string.to_utf_codepoints()
  |> list.map(fn(ascii) -> Int {
    string.utf_codepoint_to_int(ascii) - 0x30 // "0"
  })
  |> glearray.from_list()
  |> calculate_checksum()
  |> echo
}

pub fn calculate_checksum(disk_map: Array(Int)) -> Int {
  let last_file_id = { glearray.length(disk_map) - 1 } / 2
  let assert Ok(last_file_remains) = glearray.get(disk_map, last_file_id * 2)
  calculate_checksum_loop(
    disk_map,
    0,
    0,
    last_file_id,
    last_file_remains,
    0,
    dict.new(),
  )
}

fn calculate_checksum_loop(
  disk_map: Array(Int),
  map_idx: Int,
  block_idx: Int,
  last_file_id: Int,
  last_file_remains: Int,
  sum: Int,
  free_space_lengths: Dict(Int, Int),
) -> Int {
  case map_idx % 2 {
    0 -> {
      // it's a file
      let file_id = map_idx / 2
      case int.compare(file_id, last_file_id) {
        Gt -> sum
        Eq ->
          sum
          |> add_file_chunk(block_idx, last_file_remains, file_id)
        Lt -> {
          let assert Ok(length) = glearray.get(disk_map, map_idx)
          let sum =
            sum
            |> add_file_chunk(block_idx, length, file_id)
          calculate_checksum_loop(
            disk_map,
            map_idx + 1,
            block_idx + length,
            last_file_id,
            last_file_remains,
            sum,
            free_space_lengths,
          )
        }
      }
    }
    1 -> {
      // it's a free space
      case map_idx / 2 >= last_file_id {
        True -> sum
        False -> {
          let free_space_length = case
            dict.get(free_space_lengths, map_idx),
            glearray.get(disk_map, map_idx)
          {
            Ok(shrunk), _ -> {
              shrunk
            }
            Error(Nil), Ok(whole) -> {
              whole
            }
            _, _ -> {
              panic
            }
          }

          case int.compare(free_space_length, last_file_remains) {
            Gt -> {
              let sum =
                sum
                |> add_file_chunk(block_idx, last_file_remains, last_file_id)
              let block_idx = block_idx + last_file_remains
              let free_space_lengths =
                dict.insert(
                  free_space_lengths,
                  map_idx,
                  free_space_length - last_file_remains,
                )
              let last_file_id = last_file_id - 1
              let assert Ok(last_file_remains) =
                glearray.get(disk_map, last_file_id * 2)
              calculate_checksum_loop(
                disk_map,
                map_idx,
                block_idx,
                last_file_id,
                last_file_remains,
                sum,
                free_space_lengths,
              )
            }
            Eq -> {
              let sum =
                sum
                |> add_file_chunk(block_idx, last_file_remains, last_file_id)
              let block_idx = block_idx + last_file_remains
              let last_file_id = last_file_id - 1
              let assert Ok(last_file_remains) =
                glearray.get(disk_map, last_file_id * 2)
              calculate_checksum_loop(
                disk_map,
                map_idx + 1,
                block_idx,
                last_file_id,
                last_file_remains,
                sum,
                free_space_lengths,
              )
            }
            Lt -> {
              let sum =
                sum
                |> add_file_chunk(block_idx, free_space_length, last_file_id)
              let block_idx = block_idx + free_space_length
              let last_file_remains = last_file_remains - free_space_length
              calculate_checksum_loop(
                disk_map,
                map_idx + 1,
                block_idx,
                last_file_id,
                last_file_remains,
                sum,
                free_space_lengths,
              )
            }
          }
        }
      }
    }
    _ -> 0 // Idk how this is a missing pattern considering map_idx is an integer
  }
}

fn add_file_chunk(sum, begin, length, file_id) -> Int {
  sum + { begin * length + sum_from_1_to(length - 1) } * file_id
}

fn sum_from_1_to(a) -> Int {
  a * { a + 1 } / 2
}
