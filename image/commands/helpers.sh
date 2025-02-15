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
#   $1: Source directory path.
#   $2: File pattern to backup.
#
# RETURN:
#   Returns the API response.
# =====================================
github_api_call() {
  GITHUB_ACCESS_TOKEN=$(get_access_token)
  API_URL_PREFIX=${API_URL_PREFIX:-'https://api.github.com'}
  CONTENT=$(curl -sSL \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_ACCESS_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${API_URL_PREFIX}$1")
  echo "${CONTENT}"
}

#######################################
# Convert string passed to PascalCase.
#
# ARGUMENTS:
#   $1: Source directory path.
#   $2: File pattern to backup.
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
  local words=($input)
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
