#!/bin/bash

# Script to embed a few chunks as a test

echo "Testing embedding of 5 chunks..."

cd "$(dirname "$0")/.."

counter=3  # Start from 3 since we already have chunks 1 and 2
for chunk in text_chunks/bill_chunk_ac text_chunks/bill_chunk_ad text_chunks/bill_chunk_ae text_chunks/bill_chunk_af text_chunks/bill_chunk_ag; do
    chunk_id=$(printf "BBB_chunk_%03d" $counter)
    echo "Embedding $chunk as $chunk_id..."
    
    if cat "$chunk" | llm embed files "$chunk_id" --store; then
        echo "✓ Successfully embedded $chunk_id"
    else
        echo "✗ Failed to embed $chunk_id"
        exit 1
    fi
    
    counter=$((counter + 1))
    sleep 0.5  # Small delay
done

echo ""
echo "Test complete! Checking collection:"
llm collections list

echo ""
echo "Testing search:"
llm similar files -c "agriculture" -n 3
