#!/bin/bash

# Script to search embedded bill content using semantic similarity

if [ $# -eq 0 ]; then
    echo "Usage: $0 \"search query\" [number_of_results]"
    echo "Example: $0 \"agriculture nutrition\" 5"
    echo "Example: $0 \"tax policy\""
    exit 1
fi

QUERY="$1"
NUM_RESULTS="${2:-3}"  # Default to 3 results if not specified

echo "Searching for: $QUERY"
echo "Showing top $NUM_RESULTS results:"
echo "================================"

llm similar files -c "$QUERY" -n "$NUM_RESULTS"
