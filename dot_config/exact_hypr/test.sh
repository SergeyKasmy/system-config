#!/bin/sh

for test in ./tests/*; do
  echo "--- $(basename "$test")"
  lua "$test"
done
