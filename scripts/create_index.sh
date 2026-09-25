#!/usr/bin/env bash
set -euo pipefail

INDEX_NAME="explicit-tenant-a"
USER_NAME="tenant_a_admin"
USER_PASS="TenantASecure123!"

ZINC_URL="http://localhost:30080"
ADMIN_AUTH="admin:VectorAdmin123!"

echo "1. Explicitly creating Index: ${INDEX_NAME}"
curl -s -X PUT "${ZINC_URL}/api/index" \
  -u "${ADMIN_AUTH}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "'${INDEX_NAME}'",
    "storage_type": "disk"
  }' > /dev/null

echo -e "\n2. Creating restricted Role for ${INDEX_NAME}"
curl -s -X POST "${ZINC_URL}/api/role" \
  -u "${ADMIN_AUTH}" \
  -H "Content-Type: application/json" \
  -d '{
    "_id": "'${INDEX_NAME}_role'",
    "name": "'${INDEX_NAME}_role'",
    "permissions": ["'${INDEX_NAME}'"]
  }' > /dev/null

echo -e "\n3. Creating User: ${USER_NAME}"
curl -s -X POST "${ZINC_URL}/api/user" \
  -u "${ADMIN_AUTH}" \
  -H "Content-Type: application/json" \
  -d '{
    "_id": "'${USER_NAME}'",
    "name": "'${USER_NAME}'",
    "role": "'${INDEX_NAME}_role'",
    "password": "'${USER_PASS}'"
  }' > /dev/null

echo -e "\nSuccess! Tenant index and user explicitly created."
