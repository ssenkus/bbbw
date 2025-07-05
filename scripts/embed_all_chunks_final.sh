#!/bin/bash

# Script to embed all bill chunks (updated for new chunk format)

echo "🚀 Starting to embed all bill chunks..."

# Change to the project root directory
cd "$(dirname "$0")/.."

# Check how many chunks we have
total_chunks=$(ls text_chunks/bill_chunk_*.txt | wc -l)
echo "📊 Found $total_chunks chunks to embed"

# Get current number of embeddings
current_embeddings=$(llm collections list | grep "files:" -A1 | tail -1 | grep -o '[0-9]*')
echo "📈 Current embeddings in collection: $current_embeddings"

echo ""
echo "⚡ Embedding chunks (this may take a while)..."

counter=1
success_count=0
failure_count=0

for chunk in text_chunks/bill_chunk_*.txt; do
    chunk_id=$(printf "BBB_chunk_%03d" $counter)
    
    # Show progress every 10 chunks
    if [ $((counter % 10)) -eq 0 ]; then
        echo "📍 Progress: $counter/$total_chunks chunks processed"
    fi
    
    if cat "$chunk" | llm embed files "$chunk_id" --store 2>/dev/null; then
        success_count=$((success_count + 1))
    else
        echo "❌ Failed to embed $chunk_id"
        failure_count=$((failure_count + 1))
    fi
    
    counter=$((counter + 1))
    
    # Small delay to avoid rate limiting
    sleep 0.2
done

echo ""
echo "🎉 Embedding complete!"
echo "✅ Successfully embedded: $success_count chunks"
echo "❌ Failed to embed: $failure_count chunks"

echo ""
echo "📋 Final collection status:"
llm collections list

echo ""
echo "🔍 Testing search functionality:"
llm similar files -c "agriculture policy" -n 3

echo ""
echo "🎯 You can now search with:"
echo "  llm similar files -c 'your search query'"
echo "  ./scripts/search_bills.sh 'your search query'"
echo "  ./scripts/interactive_search.sh"
