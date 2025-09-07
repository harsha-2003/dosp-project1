import gleam/io
import gleam/int
import gleam/string


@external(erlang, "io", "get_line")
pub fn get_line() -> String

pub fn main() {
  io.println("Please enter a number:")

  case get_line() {
    input_string -> {
      let trimmed_string = string.trim(input_string)

      case int.parse(trimmed_string) {
        Ok(number) -> {
          io.println("You entered the number: " <> int.to_string(number))
        }
        _ -> {
          io.println("Error: That was not a valid number.")
        }
      }
    }
  }
}