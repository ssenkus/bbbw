# Semantic Search Guide for BBBW

## Overview
This guide shows you how to use semantic search with your embedded bill chunks using the `llm` tool.

## Available Search Methods

### 1. Basic Similarity Search
```bash
# Basic search with default 3 results
llm similar files -c "your search query"

# Search with specific number of results
llm similar files -c "agriculture policy" -n 5

# Search for content similar to a specific chunk ID
llm similar files BBB_chunk_01
```

### 2. Using the Search Scripts

#### Quick Search
```bash
./scripts/search_bills.sh "search query" [number_of_results]

# Examples:
./scripts/search_bills.sh "agriculture nutrition"
./scripts/search_bills.sh "tax policy" 5
./scripts/search_bills.sh "environmental regulations"
```

#### Detailed Search (with content preview)
```bash
./scripts/search_bills_detailed.sh "search query" [number_of_results]

# Examples:
./scripts/search_bills_detailed.sh "agriculture policy"
./scripts/search_bills_detailed.sh "healthcare provisions" 3
```

### 3. Advanced Search Options

#### Search with Plain Text Output
```bash
llm similar files -c "agriculture" -n 3 -p
```

#### Search with ID Prefix Filter
```bash
llm similar files -c "agriculture" --prefix "BBB_chunk"
```

#### Search from File Content
```bash
llm similar files -i path/to/query_file.txt -n 5
```

## Example Search Queries

### Topic-Based Searches
- `"agriculture and nutrition programs"`
- `"tax policy and revenue"`
- `"healthcare and medicaid"`
- `"environmental protection"`
- `"education funding"`
- `"transportation infrastructure"`

### Policy-Specific Searches
- `"SNAP benefits and work requirements"`
- `"crop insurance and farming"`
- `"medicare and social security"`
- `"clean energy initiatives"`

### Administrative Searches
- `"implementation timeline"`
- `"funding allocation"`
- `"regulatory compliance"`
- `"reporting requirements"`

## Understanding Results

Each search result includes:
- **ID**: The chunk identifier (e.g., `BBB_chunk_01`)
- **Score**: Similarity score (0.0 to 1.0, higher = more similar)
- **Content**: The actual text content (if using detailed search)

### Similarity Score Interpretation
- **0.8-1.0**: Very high similarity (exact matches, synonyms)
- **0.6-0.8**: High similarity (related concepts)
- **0.4-0.6**: Moderate similarity (tangentially related)
- **0.2-0.4**: Low similarity (some connection)
- **0.0-0.2**: Very low similarity (minimal connection)

## Collection Management

### View Collections
```bash
llm collections list
```

### View Collection Contents
```bash
llm similar files -c "test" -n 100  # Shows all embeddings
```

### Delete Collection (if needed)
```bash
llm collections delete files
```

## Tips for Better Searches

1. **Use descriptive terms**: Instead of "money", use "funding allocation" or "budget"
2. **Try different phrasings**: "agriculture" vs "farming" vs "food policy"
3. **Combine concepts**: "healthcare AND rural" vs just "healthcare"
4. **Use specific terminology**: "SNAP" vs "food stamps"
5. **Search incrementally**: Start broad, then narrow down

## Troubleshooting

### No Results Found
- Check if embeddings exist: `llm collections list`
- Try broader search terms
- Check spelling and terminology

### Poor Quality Results
- Use more specific terms
- Try different synonyms
- Increase the number of results with `-n` parameter

### Performance Issues
- Reduce the number of results requested
- Search for more specific terms to get fewer matches
