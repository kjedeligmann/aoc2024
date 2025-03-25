import day9
import gleam/list
import gleam/string
import glearray
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn first_test() {
  "12345"
  |> string.to_utf_codepoints()
  |> list.map(fn(ascii) -> Int {
    string.utf_codepoint_to_int(ascii) - 0x30
    // "0"
  })
  |> echo
  |> glearray.from_list()
  |> day9.calculate_checksum()
  |> should.equal(60)
}

pub fn second_test() {
  "2333133121414131402"
  |> string.to_utf_codepoints()
  |> list.map(fn(ascii) -> Int {
    string.utf_codepoint_to_int(ascii) - 0x30
    // "0"
  })
  |> echo
  |> glearray.from_list()
  |> day9.calculate_checksum()
  |> should.equal(1928)
}
