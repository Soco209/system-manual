#!/usr/bin/env bash
# make-build-log.sh
# Generates a timestamped build log for a MkDocs project.
#
# Usage (run from the project root, where mkdocs.yml is):
#   ./make-build-log.sh            # build only
#   ./make-build-log.sh --deploy   # build, then deploy to GitHub Pages
#
# Windows: run in Git Bash.

DEPLOY=false
[ "$1" = "--deploy" ] && DEPLOY=true

if [ ! -f mkdocs.yml ]; then
  echo "Error: mkdocs.yml not found. Run this from your project root."
  exit 1
fi

LOG="build-log-$(date +%Y%m%d-%H%M%S).txt"
STATUS=0

# Work out repo and live-site URLs from the git remote (if set)
REMOTE=$(git remote get-url origin 2>/dev/null)
REPO_URL=$(echo "$REMOTE" | sed -E 's#\.git$##; s#^git@github.com:#https://github.com/#')
USER_NAME=$(echo "$REPO_URL" | sed -E 's#https://github.com/([^/]+)/.*#\1#')
REPO_NAME=$(basename "$REPO_URL")
SITE_URL="https://${USER_NAME}.github.io/${REPO_NAME}/"

section() {
  echo
  echo "=================================================="
  echo "$1"
  echo "=================================================="
}

# Run a command, print it, show its output and exit code
run() {
  echo "\$ $*"
  "$@" 2>&1
  local code=$?
  echo "[exit code: $code]"
  [ $code -ne 0 ] && STATUS=$code
  echo
}

{
  echo "BUILD LOG: ${REPO_NAME:-mkdocs-project}"
  echo "Generated: $(date)"
  echo "Folder:    $(pwd)"

  section "ENVIRONMENT"
  run python --version
  run mkdocs --version
  run git --version
  run pip list --format=columns 2>/dev/null | grep -i -E "mkdocs|material|pdf|pymdown|weasy"

  section "REPOSITORY STATUS"
  run git status -sb
  run git log --oneline -5
  run git remote -v

  section "SOURCE FILES"
  run find docs -type f

  section "MKDOCS BUILD (strict mode: warnings count as errors)"
  run mkdocs build --strict --verbose

  section "BUILD OUTPUT (site/)"
  run ls -lh site/
  echo "PDF files found:"
  find site -name "*.pdf" -exec ls -lh {} \; 2>&1
  echo

  if [ "$DEPLOY" = true ]; then
    section "DEPLOY TO GITHUB PAGES"
    run mkdocs gh-deploy --force
  else
    section "DEPLOY"
    echo "Skipped (run with --deploy to include it)."
  fi

  section "SUMMARY"
  if [ $STATUS -eq 0 ]; then
    echo "Result: SUCCESS (no errors)"
  else
    echo "Result: FAILED (last non-zero exit code: $STATUS)"
  fi
  [ -n "$REPO_URL" ] && echo "Repo:      $REPO_URL"
  [ -n "$USER_NAME" ] && echo "Live site: $SITE_URL"
} 2>&1 | tee "$LOG"

echo
echo "Log saved to: $LOG"
