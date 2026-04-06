#!/usr/bin/env bash
set -euo pipefail

# Purpose:
# Generate PR-mode exploit-hunt demo content with both:
# 1) True positives: runtime-callable vulnerabilities (wired endpoints)
# 2) Context-only false positives: vulnerable dead code not wired to runtime entry points
#
# Default mode is dry-run. Use --apply to write files.

MODE="dry-run"
WITH_OWASP="false"
for arg in "$@"; do
  case "$arg" in
    --apply)
      MODE="apply"
      ;;
    --with-owasp)
      WITH_OWASP="true"
      ;;
    *)
      ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ "$MODE" == "apply" ]]; then
  bash "$ROOT_DIR/scripts/generate-exploit-hunt-fixtures.sh" --apply
else
  bash "$ROOT_DIR/scripts/generate-exploit-hunt-fixtures.sh"
fi

if [[ "$WITH_OWASP" == "true" ]]; then
  if [[ "$MODE" == "apply" ]]; then
    bash "$ROOT_DIR/scripts/generate-owasp-test-fixtures.sh" --apply
  else
    bash "$ROOT_DIR/scripts/generate-owasp-test-fixtures.sh"
  fi
fi

MANIFEST_PATH="$ROOT_DIR/security-test-fixtures/exploit-hunt/pr-vuln-mix-manifest.json"
if [[ "$MODE" == "apply" ]]; then
  mkdir -p "$(dirname "$MANIFEST_PATH")"
  cat >"$MANIFEST_PATH" <<'EOF'
{
  "version": 1,
  "description": "PR-mode vulnerable mix fixture manifest for exploit-hunt demos.",
  "true_positive_runtime_files": [
    "src/main/java/org/sasanlabs/service/vulnerability/exploithunt/generated/ExploitHuntCompanionController.java"
  ],
  "false_positive_non_wired_files": [
    "src/main/java/org/sasanlabs/service/vulnerability/exploithunt/deadcode/ExploitHuntCompanionGhostLibrary.java"
  ],
  "tests": [
    "src/test/java/org/sasanlabs/service/vulnerability/exploithunt/generated/ExploitHuntCompanionControllerTest.java",
    "src/test/java/org/sasanlabs/service/vulnerability/exploithunt/deadcode/ExploitHuntCompanionGhostLibraryTest.java"
  ]
}
EOF
  echo "[APPLY] created/updated: $MANIFEST_PATH"
else
  echo "[DRY-RUN] would create/update: $MANIFEST_PATH"
fi

echo "Done. Mode: $MODE"
