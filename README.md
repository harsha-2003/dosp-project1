# COP5615 Project 1

## Team Members

- **Harshavardhan Reddy Jonnala**  
  - UFID: 15118670

- **Venkata sai Tarun Reddy Chittela**  
  - UFID: 44530897

# Github ()

  Project Description:
This project demonstrates how to utilize Gleam's actor model to split out and process a computing job in parallel. The specific topic addressed is determining all starting integers for consecutive square sequences of length k whose total sum is a perfect square.
To address this, the range [1..n] is divided into smaller parts, with each allocated to a worker actor. A central boss actor monitors the workers, collects their results, and returns them to the main process.

# Overview.

 The system consists of three main components:

 Main Program (actor_squares.gleam)  - Accepts input, activates the boss actor, and outputs the final results.

 Boss Actor (boss.gleam) - In charge of distributing tasks and collecting outcomes.

 Worker Actor (worker.gleam) - Processes assigned ranges and determines if the computed sums are perfect squares.

 This architecture supports full parallel processing across many CPU cores.

 # Actor and Functionality

 # Boss Actor.

 Role: Manages the complete computation.  It divides the entire task into sections, assigns them to worker actors, and then collects the outcomes.
# Message types:

 Start - Begin the computation using n, k, and the supplied work unit size.

 WorkerReply - Provides partial results from a worker.

 WorkerDone - This indicates that a worker has finished their assigned duty.

 Behavior:  After all workers have finished, the boss transmits the entire list of results back to the main process.

 # Worker Actor.

 Purpose: Handles a certain set of initial numbers.

 # Behavior:

 It iterates across the specified range.

 Calculates the sum of k consecutive squares beginning with each integer.

 Checks whether the total is a perfect square.

# Main program.

 Reads the input values (n, k).

 Calls his boss. find_all_sums (n, k, unit_size).

 Displays any valid beginning numbers that were received.

 Serves as a client who awaits outcomes from the boss.

 # Work Unit Dimensions

 We evaluated several unit sizes, each determining how many subproblems a single worker should handle.

 Too small: results in too many workers, which increases communication overhead.

 Too large:  Parallelism decreases as there are fewer active workers.

 Through testing, a unit size of 650 achieved the optimal balance of limiting communication while boosting concurrency.

 Returns all valid beginning numbers to the boss.

 # Performance Evaluation.

 *Execution time was assessed using the calculate_time.sh script, which logs:

 Real time
 User's time
 System time
 CPU Time to Real Time Ratio
 Available cores

 Parallelism with approximately 15 cores.

 Sample Run -./calculate_time.sh./actor_squares 1000000 4.

 Real time: 0.187 seconds.

 User Time: 1.076 sec.

 System Time: 1.061 seconds

 CPU time: 2.137 seconds.

 CPU/Real Ratio: 11.43

 *The number of cores available is 16


 # Largest Problem Resolved

 The implementation was successfully tested with a maximum input size of:

 n = 3,000,000, k = 4

 For numbers higher than this, execution times become too lengthy for practical usage.
# Performance Optimization

 Tuned Unit Size  The unit size of 650 was found to be the most efficient.

 Effective Concurrency: Worker actors work independently and complete at various times, keeping cores active.

 Reduced Messaging Overhead: Workers communicate results in batches rather than reporting individual discoveries, which increases efficiency.
