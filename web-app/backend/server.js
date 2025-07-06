const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { spawn } = require('child_process');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'BBBW Search API is running' });
});

// Get collection info
app.get('/api/collections', async (req, res) => {
  try {
    const collections = await runLlmCommand(['collections', 'list']);
    res.json({ collections: collections });
  } catch (error) {
    console.error('Error fetching collections:', error);
    res.status(500).json({ error: 'Failed to fetch collections' });
  }
});

// Semantic search endpoint
app.post('/api/search', async (req, res) => {
  try {
    const { query, limit = 5, collection = 'files' } = req.body;

    if (!query) {
      return res.status(400).json({ error: 'Query is required' });
    }

    // Validate limit
    const searchLimit = Math.min(Math.max(parseInt(limit) || 5, 1), 20);

    console.log(`Searching for: "${query}" with limit: ${searchLimit}`);

    // Run the llm similar command
    const results = await runLlmCommand([
      'similar', 
      collection, 
      '-c', 
      query, 
      '-n', 
      searchLimit.toString()
    ]);

    // Parse the JSON results
    const searchResults = results
      .split('\n')
      .filter(line => line.trim())
      .map(line => {
        try {
          return JSON.parse(line);
        } catch (e) {
          console.warn('Failed to parse line:', line);
          return null;
        }
      })
      .filter(result => result !== null);

    // Get content for each result
    const enrichedResults = await Promise.all(
      searchResults.map(async (result) => {
        try {
          const content = await getChunkContent(result.id);
          return {
            ...result,
            content: content,
            contentPreview: content ? content.substring(0, 300) + '...' : null
          };
        } catch (error) {
          console.warn(`Failed to get content for ${result.id}:`, error.message);
          return {
            ...result,
            content: null,
            contentPreview: null
          };
        }
      })
    );

    res.json({
      query,
      results: enrichedResults,
      total: enrichedResults.length
    });

  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ 
      error: 'Search failed', 
      details: error.message 
    });
  }
});

// Get full content for a specific chunk
app.get('/api/content/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const content = await getChunkContent(id);
    
    if (!content) {
      return res.status(404).json({ error: 'Content not found' });
    }

    res.json({ id, content });
  } catch (error) {
    console.error('Error fetching content:', error);
    res.status(500).json({ error: 'Failed to fetch content' });
  }
});

// Helper function to run llm commands
function runLlmCommand(args) {
  return new Promise((resolve, reject) => {
    // Change to the project root directory where the embeddings are
    const projectRoot = path.resolve(__dirname, '../../');
    
    const llm = spawn('llm', args, { 
      cwd: projectRoot,
      stdio: ['pipe', 'pipe', 'pipe']
    });

    let stdout = '';
    let stderr = '';

    llm.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    llm.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    llm.on('close', (code) => {
      if (code === 0) {
        resolve(stdout.trim());
      } else {
        reject(new Error(`LLM command failed with code ${code}: ${stderr}`));
      }
    });

    llm.on('error', (error) => {
      reject(new Error(`Failed to spawn llm command: ${error.message}`));
    });
  });
}

// Helper function to get chunk content from files
async function getChunkContent(chunkId) {
  const fs = require('fs').promises;
  const projectRoot = path.resolve(__dirname, '../../');
  
  try {
    let filePath;

    if (chunkId === 'BBB_bill_sample') {
      filePath = path.join(projectRoot, 'processed_text/bill_text_sample.txt');
    } else if (chunkId.startsWith('BBB_chunk_')) {
      // Extract chunk number and convert to file name
      const chunkNum = parseInt(chunkId.replace('BBB_chunk_', ''));
      
      // Convert number to alphabetic format (1->aa, 2->ab, etc.)
      const getAlphaName = (num) => {
        let result = '';
        while (num > 0) {
          result = String.fromCharCode(97 + ((num - 1) % 26)) + result;
          num = Math.floor((num - 1) / 26);
        }
        return result || 'aa';
      };
      
      const fileName = `bill_chunk_${getAlphaName(chunkNum)}`;
      filePath = path.join(projectRoot, 'text_chunks', fileName);
    } else {
      throw new Error(`Unknown chunk ID format: ${chunkId}`);
    }

    const content = await fs.readFile(filePath, 'utf8');
    return content.trim();
  } catch (error) {
    console.warn(`Could not read content for ${chunkId}:`, error.message);
    return null;
  }
}

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Unhandled error:', error);
  res.status(500).json({ error: 'Internal server error' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

app.listen(PORT, () => {
  console.log(`🚀 BBBW Search API running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
});

module.exports = app;
