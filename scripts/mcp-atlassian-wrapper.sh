#!/bin/bash

# Atlassian MCP Server Wrapper
# This script sets up environment variables and launches the Atlassian MCP server

# Set Jira configuration variables:
# CONFLUENCE_URL, CONFLUENCE_USERNAME, CONFLUENCE_API_TOKEN
# JIRA_URL, JIRA_USERNAME, JIRA_API_TOKEN

# PyO3 maximum version is 3.13
export UV_PYTHON="/home/linuxbrew/.linuxbrew/opt/python@3.13/bin/python3.13"

# Launch the Atlassian MCP server using uvx
exec uvx mcp-atlassian
