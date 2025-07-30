#!/bin/bash

# set -e: exit immediately if a command exits with a non-zero status.
# set -u: treat unset variables as an error when substituting.
# set -o pipefail: the return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status.
set -euo pipefail

# --- Configuration ---
# Source directory is the repo root where this script lives
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ANSI color codes for a nicer CLI experience
BOLD=$(tput bold)
BLUE=$(tput setaf 4)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# App types available for selection
APP_TYPES=(
  "spring_boot_service"
  "cli_tool"
  "ml_pipeline"
  "data_pipeline"
  "mcp_server"
  "app_web"
  "service_api"
)

# --- User Interaction ---
echo -e "\n${BOLD}${BLUE}🚀 Welcome to the AI Prompt Project Generator${RESET}"
echo "${BLUE}==============================================${RESET}"
echo "This script will deploy a set of prompts to your project directory."

read -rp $'\n\e[32m📁 Enter the base path for your projects (e.g., ~/Projects): \e[0m' DEST_PARENT
# Expand the tilde (~) to the user's home directory if they use it
DEST_PARENT="${DEST_PARENT/#\~/$HOME}"

read -rp "${GREEN}📦 Enter a name for your project (this will be the directory name): ${RESET}" PROJECT_NAME

# If the parent path already ends with the project name, don't append it again.
# This makes the script more forgiving if the user provides the full project path as the parent.
if [[ "$(basename "$DEST_PARENT")" == "$PROJECT_NAME" ]]; then
    PROJECT_PATH="$DEST_PARENT"
else
    PROJECT_PATH="$DEST_PARENT/$PROJECT_NAME"
fi
echo -e "\nProject will be deployed to: ${BOLD}${PROJECT_PATH}${RESET}"
mkdir -p "$PROJECT_PATH"

echo -e "\n${BOLD}${BLUE}🧠 Select one or more application types by entering numbers separated by spaces:${RESET}"
for i in "${!APP_TYPES[@]}"; do
  printf "   ${YELLOW}%d)${RESET} %s\n" "$i" "${APP_TYPES[$i]}"
done

read -rp $'\n\e[32m> \e[0m' -a SELECTED_INDEXES

echo -e "\n${GREEN}✅ You selected:${RESET}"
SELECTED_TYPES=()
for i in "${SELECTED_INDEXES[@]}"; do
  if [[ "$i" =~ ^[0-9]+$ ]] && (( i >= 0 && i < ${#APP_TYPES[@]} )); then
    echo "   - ${APP_TYPES[$i]}"
    SELECTED_TYPES+=("${APP_TYPES[$i]}")
  else
    echo "   ! Skipping invalid selection: $i"
  fi
done
echo -e "\n${YELLOW}⚙️  Deploying prompts...${RESET}"

# --- File Operations ---
# Clean up existing app-specific prompt directories to ensure a fresh state.
# This prevents stale prompts from remaining if the selection changes on a re-run.
if [ -d "$PROJECT_PATH/prompt" ]; then
    echo "   - Cleaning up old app-specific prompts..."
    # Find all directories inside prompt/ that are not _base and remove them
    find "$PROJECT_PATH/prompt" -mindepth 1 -maxdepth 1 -type d -not -name '_base' -exec rm -rf {} +
fi

# Ensure destination structure and copy base
mkdir -p "$PROJECT_PATH/prompt/_base"
cp -f "$SRC_DIR/prompt/_base/core_prompt.md" "$PROJECT_PATH/prompt/_base/"

# Copy selected prompt folders
# `shopt -s nullglob` prevents errors if a directory contains no .md files
shopt -s nullglob
for APP in "${SELECTED_TYPES[@]}"; do
  mkdir -p "$PROJECT_PATH/prompt/$APP"
  for f in "$SRC_DIR/prompt/$APP/"*.md; do
    cp -f "$f" "$PROJECT_PATH/prompt/$APP/"
  done
done

# Copy base project instructions template, but DO NOT overwrite if it exists to prevent data loss.
if [ ! -f "$PROJECT_PATH/PROJECT.md" ]; then
  cp "$SRC_DIR/PROJECT_TEMPLATE.md" "$PROJECT_PATH/PROJECT.md"
else
  echo "   - Skipping PROJECT.md (already exists to prevent data loss)"
fi
shopt -u nullglob

# --- Config Generation ---
# Generate combined prompt (only selected app types)
COMBINED="$PROJECT_PATH/combined_prompt.md"
echo "# Combined Prompt" > "$COMBINED"
echo -e "\n---\n" >> "$COMBINED"
echo -e "# Project Context\n" >> "$COMBINED"
# Note: We are intentionally writing a reference to PROJECT.md, not its content.
echo "Refer to the user-provided 'PROJECT.md' file for specific project goals, tech stack, and architecture. That file is the primary source of truth for project-specific context." >> "$COMBINED"

echo -e "\n---\n\n# From: prompt/_base/core_prompt.md\n" >> "$COMBINED"
cat "$PROJECT_PATH/prompt/_base/core_prompt.md" >> "$COMBINED"

for APP in "${SELECTED_TYPES[@]}"; do
  for f in "$PROJECT_PATH/prompt/$APP/"*.md; do
    echo -e "\n---\n\n# From: prompt/${APP}/$(basename "$f")\n" >> "$COMBINED"
    cat "$f" >> "$COMBINED"
  done
done

# Create convenience aliases
cp -f "$COMBINED" "$PROJECT_PATH/.claude.md"
cp -f "$COMBINED" "$PROJECT_PATH/.gemini.md"

# Generate tool metadata referencing modular files
CURSOR_JSON="$PROJECT_PATH/.cursor.json"
WDS_JSON="$PROJECT_PATH/.windsurf.json"

# Build a JSON-compatible string of file paths for .cursor.json and .windsurf.json
PROMPTS_JSON="\"PROJECT.md\", \"prompt/_base/core_prompt.md\""
for APP in "${SELECTED_TYPES[@]}"; do
  for f in "$PROJECT_PATH/prompt/$APP/"*.md; do
    REL="prompt/${APP}/$(basename "$f")"
    PROMPTS_JSON+=", \"$REL\""
  done
done

cat <<EOF > "$CURSOR_JSON"
{
  "prompts": [ $PROMPTS_JSON ],
  "description": "$PROJECT_NAME prompt set"
}
EOF

cat <<EOF > "$WDS_JSON"
{
  "prompts": [ $PROMPTS_JSON ],
  "tags": ["$PROJECT_NAME"],
  "autoExpand": true
}
EOF

# Destination .gitignore for generated files
cat <<'EOF' > "$PROJECT_PATH/.gitignore"
# Generated by deploy_prompts.sh
combined_prompt.md
.claude.md
.gemini.md
EOF

# --- Final Output ---
echo -e "\n${BOLD}${GREEN}🎉 Success! Prompts deployed to: ${RESET}${PROJECT_PATH}"
echo "   - ${YELLOW}Modular prompts:${RESET} ./prompt/"
echo "   - ${YELLOW}Combined prompt:${RESET} ./combined_prompt.md (and .claude.md / .gemini.md)"
echo "   - ${YELLOW}Tool configs:${RESET}    .cursor.json / .windsurf.json"
echo -e "\n${BOLD}Next Step:${RESET} Open ${PROJECT_PATH}/PROJECT.md and fill in your project details."
echo -e ""
