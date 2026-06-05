# Rosetta-LLM Configuration

This is a LiteLLM proxy configuration for routing requests to GitHub Copilot Enterprise (Claude models).

## Setup

1. Copy the example config:
   ```bash
   cp config.json.example config.json
   ```

2. Edit `config.json` and replace `YOUR_API_KEY_HERE` with your actual API key

3. Set your GitHub Copilot access token:
   ```bash
   export COPILOT_ACCESS_TOKEN="your_token_here"
   ```

## Usage

Start the proxy server:
```bash
rosetta-llm serve --config config.json
```

The proxy will be available at `http://0.0.0.0:4000`

## Available Models

- `copilot-sonnet` / `claude-sonnet-4.5` - Claude Sonnet 4.5
- `claude-sonnet-4` / `claude-sonnet-4-0` - Aliased to Claude Sonnet 4.5
- `copilot-opus` / `claude-opus-4.5` - Claude Opus 4.5
- `copilot-haiku` / `claude-haiku-4.5` - Claude Haiku 4.5

## Security

⚠️ **Never commit `config.json`** - it contains your API keys!

The actual `config.json` is in `.gitignore` to prevent accidental commits.
