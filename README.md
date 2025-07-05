# BBBW - Bill Text Processing and Embedding

This repository contains tools for processing and embedding large legislative documents (bills) for semantic search and analysis.

## Overview

The project processes the BILLS-119hr1eas document (H.R. 1 - reconciliation bill) by:
1. Extracting clean text from HTML format
2. Splitting into manageable chunks for embedding
3. Creating searchable embeddings using the `llm` tool
4. Providing search capabilities across the entire document

## Directory Structure

```
.
├── original_documents/    # Original source documents (PDF, HTML)
├── processed_text/       # Clean text extracted from documents
├── text_chunks/         # Split text chunks ready for embedding
├── scripts/             # Processing and embedding scripts
└── temp/               # Temporary files (gitignored)
```

## Prerequisites

- [llm](https://llm.datasette.io/) command-line tool
- Python 3.x
- OpenAI API key (for embeddings)

## Setup

1. Install the llm tool:
   ```bash
   pip install llm
   ```

2. Set up your OpenAI API key:
   ```bash
   llm keys set openai
   ```

3. Set default embedding model:
   ```bash
   llm embed-models default text-embedding-3-small
   ```

## Usage

### Process Documents

The main processing workflow:

1. **Extract text from HTML documents:**
   ```bash
   python3 scripts/extract_text.py
   ```

2. **Split into chunks:**
   ```bash
   python3 scripts/split_chunks.py
   ```

3. **Embed all chunks:**
   ```bash
   ./scripts/embed_all_chunks.sh
   ```

### Search Documents

Once you've embedded the chunks, you can perform semantic searches:

#### Quick Search
```bash
./scripts/search_bills.sh "agriculture policy" 3
```

#### Detailed Search (with content preview)
```bash
./scripts/search_bills_detailed.sh "tax provisions"
```

#### Interactive Search
```bash
./scripts/interactive_search.sh
```

#### Direct LLM Commands
```bash
# Basic similarity search
llm similar files -c "agriculture and nutrition programs" -n 5

# Plain text output
llm similar files -c "healthcare" -n 3 -p

# Search similar to specific chunk
llm similar files BBB_chunk_01
```

Example searches:
```bash
llm similar files -c "SNAP benefits and work requirements"
llm similar files -c "crop insurance policy"
llm similar files -c "environmental regulations"
llm similar files -c "tax policy changes"
```

## Files

- `embed_all_chunks.sh` - Main script to embed all text chunks
- `extract_text.py` - Extract clean text from HTML documents
- `split_chunks.py` - Split large text into embedding-sized chunks

## Technical Details

- **Chunk Size**: 6KB per chunk (approximately 1,500-2,000 tokens)
- **Embedding Model**: text-embedding-3-small (OpenAI)
- **Max Context**: 8,192 tokens per embedding request
- **Collection Name**: "files" (for llm embed storage)

## Contributing

Feel free to submit issues and enhancement requests!

## License

MIT License
