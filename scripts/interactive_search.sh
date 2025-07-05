#!/bin/bash

# Interactive search script for bill embeddings

echo "🏛️  Bill Semantic Search Tool"
echo "=============================="
echo ""

while true; do
    echo "Enter your search query (or 'quit' to exit):"
    read -r query
    
    if [[ "$query" == "quit" || "$query" == "exit" || "$query" == "q" ]]; then
        echo "Goodbye!"
        break
    fi
    
    if [[ -z "$query" ]]; then
        echo "Please enter a search query."
        continue
    fi
    
    echo ""
    echo "🔍 Searching for: '$query'"
    echo "=========================="
    
    # Perform the search and format results
    results=$(llm similar files -c "$query" -n 3)
    
    if [[ -z "$results" ]]; then
        echo "No results found."
    else
        echo "$results" | while IFS= read -r line; do
            id=$(echo "$line" | python3 -c "import json, sys; print(json.load(sys.stdin)['id'])" 2>/dev/null)
            score=$(echo "$line" | python3 -c "import json, sys; print(f\"{json.load(sys.stdin)['score']:.3f}\")" 2>/dev/null)
            
            if [[ -n "$id" && -n "$score" ]]; then
                echo "📄 $id (similarity: $score)"
            fi
        done
    fi
    
    echo ""
    echo "Would you like to see content for any result? Enter ID (or press Enter to continue):"
    read -r content_id
    
    if [[ -n "$content_id" ]]; then
        echo ""
        echo "📝 Content for $content_id:"
        echo "=========================="
        
        # Show content based on ID
        if [[ "$content_id" == "BBB_bill_sample" ]]; then
            head -c 500 "processed_text/bill_text_sample.txt" 2>/dev/null || echo "Content not found"
        elif [[ "$content_id" == "BBB_chunk_01" ]]; then
            head -c 500 "text_chunks/bill_chunk_aa" 2>/dev/null || echo "Content not found"
        elif [[ "$content_id" == "BBB_chunk_02" ]]; then
            head -c 500 "text_chunks/bill_chunk_ab" 2>/dev/null || echo "Content not found"
        else
            echo "Content display not implemented for this ID"
        fi
        echo ""
    fi
    
    echo "=================================="
    echo ""
done
