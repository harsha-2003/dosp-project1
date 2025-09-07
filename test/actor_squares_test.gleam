import gleeunit
import gleeunit/should
import worker

pub fn main() {
  gleeunit.main()
}

pub fn test_sum_formula() {
  // For s=1, k=3: 1^2 + 2^2 + 3^2 = 14
  14
  |> should.equal(worker.sum_of_consecutive_squares(1, 3))
}

pub fn test_square_detection() {
  // 25 is a perfect square
  True |> should.equal(worker.is_perfect_square(25))
  False |> should.equal(worker.is_perfect_square(26))
}
