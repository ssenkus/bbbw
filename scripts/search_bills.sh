#!/bin/bash

# Script to search embedded bill content

if [ $# -eq 0 ]; then
    echo "Usage: $0 \"search query\""
    echo "Example: $0 \"agriculture nutrition\""
    exit 1
fi

QUERY="$1"

echo "Searching for: $QUERY"
echo "================================"

llm embed search files "$QUERY"
