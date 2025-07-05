#!/bin/bash

# Script to process a bill document (HTML to clean text to chunks)

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <html_file>"
    echo "Example: $0 original_documents/BILLS-119hr1eas.html"
    exit 1
fi

HTML_FILE="$1"
BASE_NAME=$(basename "$HTML_FILE" .html)

echo "Processing $HTML_FILE..."

# Change to project root
cd "$(dirname "$0")/.."

# Extract clean text
echo "Extracting clean text..."
python3 -c "
import re
import sys

with open('$HTML_FILE', 'r') as f:
    content = f.read()

# Remove HTML tags
text = re.sub(r'<[^>]+>', '', content)
# Remove extra whitespace and decode entities
text = re.sub(r'\s+', ' ', text).strip()
text = text.replace('&nbsp;', ' ')
text = text.replace('&amp;', '&')
text = text.replace('&lt;', '<')
text = text.replace('&gt;', '>')

with open('processed_text/${BASE_NAME}_clean.txt', 'w') as f:
    f.write(text)

print(f'Clean text saved. Length: {len(text)} characters')
"

# Split into chunks
echo "Creating chunks..."
split -b 6000 "processed_text/${BASE_NAME}_clean.txt" "text_chunks/${BASE_NAME}_chunk_"

echo "✓ Processing complete!"
echo "Clean text: processed_text/${BASE_NAME}_clean.txt"
echo "Chunks: text_chunks/${BASE_NAME}_chunk_*"
