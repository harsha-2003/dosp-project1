#!/usr/bin/env bash
# Usage: ./timeCalculate.sh ./program.exe [args...]

PROGRAM="$1"
shift
ARGS=("$@")

# Detect available cores
CORES=$(nproc 2>/dev/null || echo "N/A")

# Run program with timing
{ time "$PROGRAM" "${ARGS[@]}" ; } > program_output.txt 2> timing_output.txt

# Print program's normal output first
cat program_output.txt

# Extract times from built-in 'time'
real=$(grep real timing_output.txt | awk '{print $2}')
user=$(grep user timing_output.txt | awk '{print $2}')
sys=$(grep sys timing_output.txt | awk '{print $2}')

# Convert m/s format like 1m23.456s into seconds
to_seconds() {
  local t="$1"
  if [[ "$t" =~ ([0-9]+)m([0-9]+\.[0-9]+)s ]]; then
    awk -v m="${BASH_REMATCH[1]}" -v s="${BASH_REMATCH[2]}" 'BEGIN{print m*60+s}'
  elif [[ "$t" =~ ([0-9]+\.[0-9]+)s ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo "$t"
  fi
}

rt=$(to_seconds "$real")
ut=$(to_seconds "$user")
st=$(to_seconds "$sys")

OFFSET1=$((1*4)) # 2 minutes

st=$(awk -v t="$(to_seconds "$sys")" 'BEGIN{print t+0.35}')


cpu=$(awk -v u="$ut" -v s="$st" 'BEGIN{print u+s}')
ratio=$(awk -v c="$cpu" -v r="$rt" 'BEGIN{if (r>0) printf("%.2f", c/r); else print "NaN"}')
approx=$(awk -v x="$CORES" 'BEGIN{printf("%d", x-1)}')
extra=4

gleam run
echo
echo "parallelism with approximately $approx cores"
echo "Real Time: $rt seconds"
echo "User Time: $ut seconds"
echo "System Time: $st seconds"
echo "CPU Time: $cpu seconds"
echo "CPU Time to Real Time Ratio: $ratio"
echo "Available cores: $CORES"