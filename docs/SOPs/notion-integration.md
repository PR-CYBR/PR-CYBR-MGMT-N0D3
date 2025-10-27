# Notion Integration SOP

## Overview

This SOP covers the integration of Notion for automated documentation synchronization with PR-CYBR-MGMT-N0D3.

## Prerequisites

- Notion account (free or paid)
- Notion workspace access
- Notion API access

## Setup

### 1. Create Notion Integration

1. Go to [https://www.notion.so/my-integrations](https://www.notion.so/my-integrations)
2. Click "+ New integration"
3. Name: `PR-CYBR Management`
4. Select associated workspace
5. Submit

### 2. Get API Token

1. Copy the "Internal Integration Token"
2. Store in GitHub Secrets: `NOTION_API_KEY`
3. Add to `.env`:

   ```bash
   NOTION_API_KEY=secret_xxxxx
   ```

### 3. Create Database

1. Create a new database in Notion
2. Set up columns:
   - Name (title)
   - Type (select: SOP, Architecture, Config)
   - Status (select: Draft, Review, Published)
   - Last Updated (date)
   - Source (text)

3. Share database with integration:
   - Click "..." menu
   - Add connections → Select your integration

4. Copy database ID from URL:
   ```
   https://notion.so/xxxxxxxxxxxxx?v=yyyyy
   Database ID: xxxxxxxxxxxxx
   ```

5. Add to `.env`:

   ```bash
   NOTION_DATABASE_ID=xxxxxxxxxxxxx
   ```

## Usage

### Sync Documentation

Run the sync script:

```bash
./scripts/integrations/notion-sync.sh
```

### What Gets Synced

- All markdown files in `docs/`
- README.md
- Specification files from `.specify/`

### Sync Behavior

- Creates new pages for new documents
- Updates existing pages when content changes
- Preserves Notion-specific formatting
- Maintains document hierarchy

## Configuration

### Environment Variables

```bash
# Required
NOTION_API_KEY=secret_xxxxx
NOTION_DATABASE_ID=xxxxxxxxxxxxx

# Optional
NOTION_SYNC_INTERVAL=3600  # Sync every hour (in seconds)
```

### Sync Filters

Edit `scripts/integrations/notion-sync.sh` to customize:

- Which directories to sync
- File patterns to include/exclude
- Metadata to extract

## Troubleshooting

### Authentication Error

**Solution**: Verify API key is correct and has workspace access

### Database Not Found

**Solution**: Ensure database is shared with integration

### Sync Fails

**Solution**: Check Notion API rate limits, wait and retry

## References

- [Notion API Documentation](https://developers.notion.com/)
- PR-CYBR Architecture: `docs/architecture/system-overview.md`
