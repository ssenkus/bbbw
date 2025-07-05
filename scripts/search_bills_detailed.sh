#!/bin/bash

# Enhanced search script that shows both similarity scores and content

if [ $# -eq 0 ]; then
    echo "Usage: $0 \"search query\" [number_of_results]"
    echo "Example: $0 \"agriculture nutrition\" 5"
    exit 1
fi

QUERY="$1"
NUM_RESULTS="${2:-3}"

echo "🔍 Semantic Search: '$QUERY'"
echo "📊 Showing top $NUM_RESULTS most similar chunks:"
echo "================================================"

# Get search results in JSON format
RESULTS=$(llm similar files -c "$QUERY" -n "$NUM_RESULTS")

# Parse and display results with content
echo "$RESULTS" | while IFS= read -r line; do
    # Extract ID and score from JSON
    ID=$(echo "$line" | python3 -c "import json, sys; print(json.load(sys.stdin)['id'])")
    SCORE=$(echo "$line" | python3 -c "import json, sys; print(f\"{json.load(sys.stdin)['score']:.3f}\")")
    
    echo ""
    echo "📄 Chunk ID: $ID"
    echo "🎯 Similarity Score: $SCORE"
    echo "📝 Content:"
    echo "---"
    
    # Find and display the actual content
    if [[ "$ID" == "BBB_chunk_"* ]]; then
        # Extract chunk number from ID (e.g., BBB_chunk_001 -> 001)
        CHUNK_NUM=$(echo "$ID" | sed 's/BBB_chunk_//')
        
        # Convert to alphabetic format for file names (001 -> aa, 002 -> ab, etc.)
        if [ "$CHUNK_NUM" -eq 1 ]; then
            CHUNK_FILE="text_chunks/bill_chunk_aa"
        elif [ "$CHUNK_NUM" -eq 2 ]; then
            CHUNK_FILE="text_chunks/bill_chunk_ab"
        else
            # For higher numbers, we'd need more conversion logic
            CHUNK_FILE="text_chunks/bill_chunk_$(printf "%02x" $((CHUNK_NUM - 1)) | tr '0123456789' 'abcdefghij')"
        fi
        
        if [ -f "$CHUNK_FILE" ]; then
            head -c 300 "$CHUNK_FILE" | tr '\n' ' '
            echo "..."
        else
            echo "Content file not found: $CHUNK_FILE"
        fi
    elif [[ "$ID" == "BBB_bill_sample" ]]; then
        head -c 300 "processed_text/bill_text_sample.txt" | tr '\n' ' '
        echo "..."
    fi
    
    echo ""
    echo "==============================================="
done
