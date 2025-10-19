#!/bin/bash

##############################################################################
# Simple PDF Validation Test Script
#
# Usage:
#   ./test-pdf.sh <path-to-pdf>
#
# Example:
#   ./test-pdf.sh ~/Desktop/contract.pdf
#   ./test-pdf.sh document.pdf
#
##############################################################################

API_URL="http://localhost:7777/validate"

# Check if file argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-pdf>"
    echo "Example: $0 ~/Desktop/contract.pdf"
    exit 1
fi

FILE="$1"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE"
    exit 1
fi

FILENAME=$(basename "$FILE")

echo "Validating: $FILE"
echo "File name: $FILENAME"
echo ""

# Encode PDF to Base64
echo "Encoding to Base64..."
B64=$(base64 -i "$FILE")

# Send to API
echo "Sending to REST API..."
echo ""

RESPONSE=$(printf '{"filename":"%s","document":"%s","reportType":"DETAILED"}' "$FILENAME" "$B64" | \
    curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d @-)

# Display result
if command -v jq &> /dev/null; then
    echo "$RESPONSE" | jq '.'
else
    echo "$RESPONSE"
fi
