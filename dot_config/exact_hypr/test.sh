#!/bin/sh

for test in ./tests/*_test.lua; do
  echo "--- $(basename "$test")"
  lua "$test"
done
