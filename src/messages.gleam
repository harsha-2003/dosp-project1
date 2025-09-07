import gleam/erlang/process

// Messages workers can receive
pub type WorkerMsg {
  Scan(start: Int, end_: Int, k: Int, boss: process.Subject(BossMsg))
  WorkerStop
}

// Messages boss can receive
pub type BossMsg {
  Start(n: Int, k: Int, work_unit: Int, client: process.Subject(List(Int)))
  WorkerReply(List(Int))
  WorkerDone
  Stop
}
