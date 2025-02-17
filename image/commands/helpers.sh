#!/bin/bash
if [[ "${DEBUG}" == "true" ]]; then
  set -x
fi

# =====================================
# Generates an identifier that will be used as a
# directory name to save the files used in the scripts.
#
# RETURN:
#   A string of 8 characters.
# =====================================
generate_id() {
  tr -dc A-Za-z0-9 </dev/urandom | head -c 8; echo
}

# =====================================
# Creates and returns the logs directory path
# according to the identifier.
#
# ARGUMENTS:
#   $1: Identifier of the process.
#
# RETURN:
#   Logs directory path.
# =====================================
get_id_dir() {
  ID_DIR="/tmp/logs/$1"
  mkdir -p "${ID_DIR}"
  echo "${ID_DIR}"
}

# =====================================
# Checks and returns the GitHub access token.
#
# ARGUMENTS:
#   $GITHUB_ACCESS_TOKEN (optional): GitHub access token.
#
# RETURN:
#   GitHub access token.
# =====================================
get_access_token() {
  GITHUB_ACCESS_TOKEN=${GITHUB_ACCESS_TOKEN:-''}
  if [[ -z "${GITHUB_ACCESS_TOKEN}" ]]; then
    echo "You must set an access token to GitHub via the GITHUB_ACCESS_TOKEN environment variable."
    exit 1
  fi
  echo "${GITHUB_ACCESS_TOKEN}"
}

# =====================================
# Executes a call to the GitHub API.
#
# ARGUMENTS:
#   $GITHUB_ACCESS_TOKEN: GitHub access token.
#   $API_URL_PREFIX: GitHub API URL.
#   $1: GitHub API endpoint.
#
# RETURN:
#   Returns the API response.
# =====================================
github_api_call() {
  GITHUB_ACCESS_TOKEN=$(get_access_token)
  API_URL_PREFIX=${API_URL_PREFIX:-'https://api.github.com'}
  local API_ENDPOINT=$1
  CONTENT=$(curl -sSL \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_ACCESS_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${API_URL_PREFIX}${API_ENDPOINT}")
  echo "${CONTENT}"
}

#######################################
# It takes the contents of several JSON
# files and combines them into a single file.
#
# ARGUMENTS:
#   $1: GitHub API endpoint.
#   $2: The directory where the JSON files will be stored.
#######################################
get_all_resources() {
  API_ENDPOINT=$1
  CMD_DIR=$2
  PAGE=1
  HAS_MORE=true
  while [ "${HAS_MORE}" = true ]; do
    RESOURCES=$(github_api_call "${API_ENDPOINT}${PAGE}")

    if [ "$(echo "${RESOURCES}" | jq 'length')" -eq 0 ]; then
      HAS_MORE=false
    else
      echo "${RESOURCES}" > "${CMD_DIR}/page_${PAGE}.json"
      ((PAGE++))
    fi
  done
}

#######################################
# It takes the contents of several JSON
# files and combines them into a single file.
#
# ARGUMENTS:
#   $1: The directory where the JSON files are stored.
#   $2: File that will be generated at the end.
#   $3: The jq filter that will be applied to the JSON files.
#######################################
merge_all_files_into_one() {
  CMD_DIR=$1
  OUTPUT_FILE=$2
  JQ_FILTER=${3:-".[]"}
  if [ -n "$(find "${CMD_DIR}"/ -name '*.json' 2>/dev/null)" ]
  then
    jq -s "${JQ_FILTER}" "${CMD_DIR}"/*.json > "${OUTPUT_FILE}"
    echo "${OUTPUT_FILE} generated."
  fi
}

#######################################
# Convert string value to PascalCase.
#
# ARGUMENTS:
#   $1: String value.
#
# RETURN:
#   $1 but in PascalCase.
#   Example: If $1 is `validate-docbr`, the return will be `ValidateDocbr`.
#######################################
to_pascal_case() {
  local input="${1:-$(cat)}"

  # Handle empty input
  if [ -z "${input// /}" ]; then
    echo ""
    return
  fi

  # Replace separators with spaces
  input=${input//_/ }
  input=${input//-/ }
  input=${input//./ }

  # Split into words and capitalize each
  local words=("${input}")
  local result=""

  # Process each word
  for word in "${words[@]}"; do
    # Skip empty words
    if [ -n "$word" ]; then
      # Capitalize first letter, lowercase rest
      result+=${word^}
    fi
  done

  echo "${result}"
}

#######################################
# Convert string value to lowercase.
#
# ARGUMENTS:
#   $1: String value.
#
# RETURN:
#   $1 but in PascalCase.
#   Example: If $1 is `validate-docbr`, the return will be `ValidateDocbr`.
#######################################
to_lower_case() {
  echo "${1}" | tr '[:upper:]' '[:lower:]' | sed 's/[-\.]/_/g'
}
