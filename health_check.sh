#!/bin/bash
# Health check for Blue-Green deployment
# Check if the service is up
BLUE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081)
GREEN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082)

if [ "$BLUE_STATUS" -eq 200 ]; then
  echo "Blue is healthy"
  exit 0
elif [ "$GREEN_STATUS" -eq 200 ]; then
  echo "Green is healthy"
  exit 0
else
  echo "Both environments are unhealthy"
  exit 1
fi
