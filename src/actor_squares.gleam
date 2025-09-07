import gleam/io
import gleam/int
import gleam/list
import boss
import gleam/string


@external(erlang, "io", "get_line")
pub fn get_line(prompt: String) -> String


pub fn main() {

   
  io.println("Please enter n:")
  let n =
    case get_line("") |> string.trim |> int.parse {
      Ok(n) -> n
      Error(_) -> 0
    }

  
  io.println("Please enter k:")
  let k =
    case get_line("") |> string.trim |> int.parse {
      Ok(n) -> n
      Error(_) -> 0
    }

 
  let result = boss.find_all(n, k, 1000)
  io.println("sum of consecutive squares:")
  case result {
    
    Ok(starts) ->
      starts |> list.each(fn(s) { 
        io.println(int.to_string(s)) })
    Error(msg) -> io.println("Error: " <> msg)
  }
}
