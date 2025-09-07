import gleam/list
import gleam/int
import gleam/float
import gleam/otp/actor
import gleam/erlang/process as process
import gleam/result
import messages.{type WorkerMsg, Scan, WorkerStop, WorkerReply, WorkerDone}

// Worker stays alive until told to stop
pub fn start() -> Result(process.Subject(WorkerMsg), actor.StartError) {
  actor.new(Nil)
  |> actor.on_message(handle_message)
  |> actor.start
  |> result.map(fn(started) { started.data })
}

fn handle_message(_state: Nil, msg: WorkerMsg) -> actor.Next(Nil, WorkerMsg) {
  case msg {
    Scan(start, end_, k, boss_subject) -> {
      let results = scan_range(start, end_, k)
      process.send(boss_subject, WorkerReply(results))
      process.send(boss_subject, WorkerDone)
      actor.continue(Nil) // stay alive
    }

    WorkerStop -> actor.stop()
  }
}

// Scan a range and return starting numbers whose sums of squares are perfect squares
fn scan_range(start: Int, end_: Int, k: Int) -> List(Int) {
  loop(start, [], end_, k)
}

fn loop(s: Int, acc: List(Int), end_: Int, k: Int) -> List(Int) {
  case s > end_ {
    True -> list.reverse(acc)
    False -> {
      let sumsq = sum_of_consecutive_squares(s, k)
      let acc2 = case is_perfect_square(sumsq) {
        True -> [s, ..acc]
        False -> acc
      }
      loop(s + 1, acc2, end_, k)
    }
  }
}

pub fn is_perfect_square(n: Int) -> Bool {
  case n < 0 {
    True -> False
    False -> case int.square_root(n) {
      Ok(r) -> {
        let i = float.round(r)
        i * i == n
      }
      Error(_) -> False
    }
  }
}

// Closed-form formula for sum of k consecutive squares starting at s
pub fn sum_of_consecutive_squares(s: Int, k: Int) -> Int {
  let a = k * s * s
  let b = k * {k - 1} * s
  let c = {k - 1} * k * {2 * k - 1} / 6
  a + b + c
}
