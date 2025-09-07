import gleam/list
import gleam/int
import gleam/erlang/process as process
import gleam/otp/actor
import worker
import messages.{type BossMsg, Start, WorkerReply, WorkerDone, Stop, Scan}

pub type BossState {
  Idle
  Running(remaining: Int, acc: List(Int), client: process.Subject(List(Int)))
}

pub fn find_all(n: Int, k: Int, work_unit: Int) -> Result(List(Int), String) {
  let assert Ok(boss_actor) =
    actor.new(Idle)
    |> actor.on_message(handle_message)
    |> actor.start

  // auto-adjust work_unit to reduce overhead
  let work_unit = adjust_work_unit(n, work_unit)

  let chunks = chunk_ranges(n, work_unit)
  let client_subject = process.new_subject()

  // Start the boss
  actor.send(boss_actor.data, Start(n, k, work_unit, client_subject))

  // Dispatch *all* chunks in parallel – one worker per chunk
  chunks
  |> list.each(fn(range) {
    let assert Ok(w) = worker.start()
    actor.send(w, Scan(range.start, range.end_, k, boss_actor.data))
  })

  // Collect results (with generous timeout)
  case process.receive(client_subject, within: 60_000) {
    Ok(starts) -> Ok(starts)
    Error(Nil) -> Error("Timed out waiting for boss")
  }
}

fn handle_message(state: BossState, msg: BossMsg) -> actor.Next(BossState, BossMsg) {
  case state, msg {
    Idle, Start(n, _k, work_unit, client) -> {
      let remaining = how_many_chunks(n, work_unit)
      Running(remaining, [], client) |> actor.continue
    }

    Running(remaining, acc, client), WorkerReply(partial) -> {
      Running(remaining, list.append(acc, partial), client) |> actor.continue
    }

    Running(remaining, acc, client), WorkerDone -> {
      let new_remaining = remaining - 1
      case new_remaining == 0 {
        True -> {
          process.send(client, acc)
          actor.stop()
        }
        False -> Running(new_remaining, acc, client) |> actor.continue
      }
    }

    _, Stop -> actor.stop()
    _, _ -> actor.continue(state)
  }
}

pub type Range {
  Range(start: Int, end_: Int)
}

fn chunk_ranges(n: Int, work_unit: Int) -> List(Range) {
  go(1, [], n, work_unit)
}

fn go(s: Int, acc: List(Range), n: Int, work_unit: Int) -> List(Range) {
  case s > n {
    True -> list.reverse(acc)
    False -> {
      let e = int.min(s + work_unit - 1, n)
      go(s + work_unit, [Range(s, e), ..acc], n, work_unit)
    }
  }
}

fn how_many_chunks(n: Int, work_unit: Int) -> Int {
  let assert Ok(q) = int.divide(n + work_unit - 1, by: work_unit)
  q
}

// Pick a work_unit that avoids spawning thousands of workers
fn adjust_work_unit(n: Int, requested: Int) -> Int {
  let cores = 10
  let desired_chunks = cores * 8 // ~80 chunks total
  case int.divide(n + desired_chunks - 1, by: desired_chunks) {
    Ok(value) -> int.max(1, int.max(requested, value))
    Error(_) -> requested
  }
}
