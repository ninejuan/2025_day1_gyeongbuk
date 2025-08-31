#!/bin/bash
curl -u admin:Skill53## -XPOST "<OPENSEARCH_ENDPOINT>/app-log/_doc" \
-H "Content-Type: application/json" \
-d '{
  "date": "2025/06/14",
  "time": "07:21:30",
  "timestamp": "2025-06-14T07:21:30Z",
  "method": "GET",
  "path": "/green",
  "ip": "192.168.2.220",
  "port": "43422"
}'