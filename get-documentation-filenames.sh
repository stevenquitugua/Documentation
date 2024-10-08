#!/bin/sh
name: Get Filename from GitHub API

on: 
  workflow_dispatch:

jobs:
  get-filenames:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the repository
        uses: actions/checkout@v3

      - name: Install jq
        run: sudo apt-get install jq

      - name: Get filenames using curl and store in a variable
        id: get_filenames
        run: |
          response=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/stevenquitugua/Documentation/contents/ || { echo "Curl failed"; exit 1; })
          exclude_files=("README.md" ".gitignore" ".github")
          echo "$response" | jq --argjson exclude_files '["README.md", ".gitignore", ".github"]' '[.[] | select((.name as $name | $exclude_files | index($name)) | not)] | .[].name' > filenames.json
          if [ ! -s filenames.json ]; then
            echo "No filenames found or filtering failed!"
            exit 1
          fi
          echo "Filtered Filenames:"
          cat filenames.json

      - name: Use the curl output in another step
        run: |
          echo "Processing filenames from the filtered API response:"
          cat filenames.json
