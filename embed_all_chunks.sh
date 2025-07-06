#!/bin/bash

# Script to embed all bill chunks into the BBB collection

echo "Starting to embed all bill chunks..."

counter=1
for chunk in bill_chunk_*; do
    chunk_id=$(printf "BBB_chunk_%03d" $counter)
    echo "Embedding $chunk as $chunk_id..."
    
    if cat "$chunk" | llm embed files "$chunk_id"; then
        echo "✓ Successfully embedded $chunk_id"
    else
        echo "✗ Failed to embed $chunk_id"
    fi
    
    counter=$((counter + 1))
    
    # Small delay to avoid rate limiting
    sleep 0.5
done

echo "Finished embedding all chunks!"
echo "You can now search the collection with: llm embed search files 'your search query'"
