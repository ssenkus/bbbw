#!/bin/bash

# Script to embed all bill chunks efficiently using llm embed-multi

echo "Starting to embed all bill chunks using batch processing..."

# Change to the project root directory
cd "$(dirname "$0")/.."

# Check how many chunks we have
total_chunks=$(ls text_chunks/bill_chunk_* | wc -l)
echo "Found $total_chunks chunks to embed"

# Use individual embedding approach for better reliability
echo "Embedding chunks individually..."
counter=1
successful=0
failed=0

for chunk in text_chunks/bill_chunk_*; do
    chunk_id=$(printf "BBB_chunk_%03d" $counter)
    
    echo "Embedding $chunk_id... ($counter/$total_chunks)"
    
    if cat "$chunk" | llm embed files "$chunk_id" --store; then
        successful=$((successful + 1))
    else
        echo "❌ Failed to embed $chunk_id"
        failed=$((failed + 1))
    fi
    
    counter=$((counter + 1))
    
    # Progress update every 10 chunks
    if [ $((counter % 10)) -eq 0 ]; then
        echo "Progress: $counter/$total_chunks (✅ $successful successful, ❌ $failed failed)"
    fi
    
    # Small delay to avoid rate limiting
    sleep 0.2
done

echo ""
echo "Embedding complete: ✅ $successful successful, ❌ $failed failed"

if [ $successful -gt 0 ]; then
    echo "✅ Successfully embedded chunks!"
    
    # Verify the results
    echo ""
    echo "Verification:"
    llm collections list
    
    echo ""
    echo "Test search:"
    llm similar files -c "agriculture" -n 3
else
    echo "No chunks were successfully embedded"
fi

echo ""
echo "Embedding complete! You can now search with:"
echo "  llm similar files -c 'your search query'"
echo "  ./scripts/search_bills.sh 'your search query'"
