#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

FILE_TO_WATCH="maplibre_offline.ts"
BUILD_COMMAND="esbuild maplibre_offline.ts --bundle --outfile=./maplibre_offline.js --sourcemap"

# Start HTTP server in background
echo -e "${GREEN}Starting HTTP server on port 8000...${NC}"

FILENAME=protomaps\(vector\)ODbL_firenze.pmtiles
# curl https://pmtiles.io/protomaps\(vector\)ODbL_firenze.pmtiles -o 
if [ -f $FILENAME ]; then
echo "${GREEN}$FILENAME already exists, starting server"
else
    echo "Downloading $FILENAME..."
    curl -s "https://pmtiles.io/$FILENAME" -o $FILENAME
    echo "${GREEN}Download complete. Starting http server."
fi


python3 -m http.server 8000 > /dev/null 2>&1 &
HTTP_SERVER_PID=$!
echo -e "${GREEN}✓ HTTP server started (PID: $HTTP_SERVER_PID)${NC}"
echo -e "${YELLOW}  Access at: http://localhost:8000${NC}\n"

# Cleanup function to stop server on exit
cleanup() {
    echo -e "\n${YELLOW}Stopping HTTP server...${NC}"
    kill $HTTP_SERVER_PID 2>/dev/null
    echo -e "${GREEN}✓ Cleanup complete${NC}"
    exit 0
}

# Trap Ctrl+C and other exit signals
trap cleanup SIGINT SIGTERM EXIT

echo -e "${GREEN}Starting file watcher for ${FILE_TO_WATCH}${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}\n"

# Initial build
echo -e "${YELLOW}Running initial build...${NC}"
if eval $BUILD_COMMAND; then
    echo -e "${GREEN}✓ Initial build successful${NC}\n"
else
    echo -e "${RED}✗ Initial build failed${NC}\n"
fi

# Watch for changes
while true; do
    # Get the current modification time
    if [ -f "$FILE_TO_WATCH" ]; then
        CURRENT_TIME=$(stat -f %m "$FILE_TO_WATCH" 2>/dev/null || stat -c %Y "$FILE_TO_WATCH" 2>/dev/null)
        
        # Wait for file to change
        while [ -f "$FILE_TO_WATCH" ]; do
            NEW_TIME=$(stat -f %m "$FILE_TO_WATCH" 2>/dev/null || stat -c %Y "$FILE_TO_WATCH" 2>/dev/null)
            
            if [ "$NEW_TIME" != "$CURRENT_TIME" ]; then
                echo -e "${YELLOW}Change detected! Rebuilding...${NC}"
                if eval $BUILD_COMMAND; then
                    echo -e "${GREEN}✓ Build successful at $(date +%H:%M:%S)${NC}\n"
                else
                    echo -e "${RED}✗ Build failed at $(date +%H:%M:%S)${NC}\n"
                fi
                CURRENT_TIME=$NEW_TIME
                break
            fi
            
            sleep 1
        done
    else
        echo -e "${RED}Error: ${FILE_TO_WATCH} not found!${NC}"
        exit 1
    fi
done