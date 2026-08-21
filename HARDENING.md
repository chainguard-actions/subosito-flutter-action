<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.19.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.19.0** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Set action inputs' run: block in action.yaml directly interpolates multiple ${{ inputs.* }} expressions into the shell command string. Most inputs are single-quoted (e.g., -n '${{ inputs.flutter-version }}'), but single-quoting does not prevent YAML template substitution — the expression is expanded before the shell sees it, so a value containing a single-quote can break out of the quoting. Critically, `${{ inputs.channel }}` on the final line is completely unquoted, allowing direct shell injection: `$GITHUB_ACTION_PATH/setup.sh -p ... ${{ inputs.channel }}`. An attacker-controlled channel value can inject arbitrary shell commands.

Locations:

- `action.yaml:93`
- `action.yaml:103`

### script-injection (severity: high)

Rule (a): The 'Run setup script' run: block in action.yaml directly interpolates ${{ steps.flutter-action.outputs.* }} expressions into the shell command string. The outputs VERSION, ARCHITECTURE, CACHE-PATH, PUB-CACHE-PATH are single-quoted (still rule-a violations), and `${{ steps.flutter-action.outputs.CHANNEL }}` is completely unquoted on the final argument line, allowing shell injection if the output contains shell metacharacters.

Locations:

- `action.yaml:113`
- `action.yaml:118`

### script-injection (severity: high)

Rule (a): The 'Echo outputs' run: block in .github/workflows/workflow.yaml directly interpolates ${{ runner.os }}, ${{ runner.arch }}, ${{ steps.flutter-action.outputs.CACHE-PATH }}, ${{ steps.flutter-action.outputs.CACHE-KEY }}, ${{ steps.flutter-action.outputs.CHANNEL }}, ${{ steps.flutter-action.outputs.VERSION }}, and ${{ steps.flutter-action.outputs.ARCHITECTURE }} directly into shell echo commands without quoting. Example: `echo RUNNER-OS=${{ runner.os }}` — any expression containing shell metacharacters would be interpreted by the shell.

Locations:

- `.github/workflows/workflow.yaml:52`

### github-env-injection (severity: high)

setup.sh writes user-controlled values to $GITHUB_ENV and $GITHUB_PATH without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). Specifically: (1) `echo "FLUTTER_ROOT=$CACHE_PATH"` and `echo "PUB_CACHE=$PUB_CACHE"` are written to $GITHUB_ENV — $CACHE_PATH is derived from the user-controlled `cache-path` input and channel/version/arch values. (2) `echo "$CACHE_PATH/bin"`, `echo "$CACHE_PATH/bin/cache/dart-sdk/bin"`, and `echo "$PUB_CACHE/bin"` are written to $GITHUB_PATH. A newline embedded in any of these values would allow injecting arbitrary environment variables or PATH entries.

Locations:

- `setup.sh:175`
- `setup.sh:180`

### unpinned-uses (severity: high)

action.yaml uses `actions/cache@v4` (a mutable tag reference) in two composite action steps. These should be pinned to a full 40-character commit SHA to prevent supply-chain attacks via tag mutation. Failing references: `actions/cache@v4` (appears twice).

Locations:

- `action.yaml:106`
- `action.yaml:113`

### unpinned-uses (severity: high)

.github/workflows/workflow.yaml uses multiple mutable tag/branch references instead of pinned commit SHAs. Failing references: `actions/checkout@v4` (6 occurrences) and `ludeeus/action-shellcheck@master` (branch reference — especially dangerous as `master` is a moving target).

Locations:

- `.github/workflows/workflow.yaml:18`
- `.github/workflows/workflow.yaml:20`
- `.github/workflows/workflow.yaml:43`
- `.github/workflows/workflow.yaml:88`
- `.github/workflows/workflow.yaml:103`
- `.github/workflows/workflow.yaml:118`

### missing-permissions (severity: medium)

.github/workflows/workflow.yaml has no top-level `permissions:` key and no job-level `permissions:` key on any of its jobs (lint_shellcheck, test_channel, test_cache, test_version_file, test_print_output_x64, test_print_output_arm64). The workflow is triggered by `pull_request`, which means it runs with the default token permissions (read for most scopes, but write for some depending on repository settings). Explicit minimal permissions should be declared.

Locations:

- `.github/workflows/workflow.yaml:1`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:100`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version-file }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:101`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.architecture }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:102`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:103`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:104`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:105`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:106`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.git-source }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:107`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.channel }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:108`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions, static-inline-injection

**Notes:**

Fixed all findings across action.yaml, setup.sh, and .github/workflows/workflow.yaml:

1. action.yaml - Set action inputs step: Moved all ${{ inputs.* }} expressions (flutter-version, flutter-version-file, architecture, cache-key, cache-path, pub-cache-key, pub-cache-path, git-source, channel) to an env: block. The previously unquoted ${{ inputs.channel }} is now safely referenced as "$INPUT_CHANNEL".

2. action.yaml - Run setup script step: Moved all ${{ steps.flutter-action.outputs.* }} expressions (VERSION, ARCHITECTURE, CACHE-PATH, PUB-CACHE-PATH, CHANNEL) to an env: block. The previously unquoted CHANNEL output is now safely referenced as "$FLUTTER_ACTION_CHANNEL".

3. action.yaml - Pinned actions/cache@v4 to SHA 0057852bfaa89a56745cba8c7296529d2fc39830 (both occurrences).

4. setup.sh - Replaced echo with printf + tr -d '\n\r' sanitization for all values written to $GITHUB_ENV (FLUTTER_ROOT, PUB_CACHE) and $GITHUB_PATH (three path entries).

5. workflow.yaml - Echo outputs step: Moved all ${{ runner.* }} and ${{ steps.flutter-action.outputs.* }} expressions to an env: block.

6. workflow.yaml - Pinned actions/checkout@v4 to SHA 11d5960a326750d5838078e36cf38b85af677262 (all 6 occurrences across lint_shellcheck, test_channel, test_cache, test_version_file, test_print_output_x64, test_print_output_arm64 jobs).

7. workflow.yaml - Pinned ludeeus/action-shellcheck@master to SHA 00b27aa7cb85167568cb48a3838b75f4265f2bca.

8. workflow.yaml - Added top-level permissions: contents: read block.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the PRINT_ONLY block in setup.sh that writes to $GITHUB_OUTPUT. Replaced 7 unsanitized `echo` statements with `printf '%s' "$VAR" | tr -d '\n\r'` sanitized writes to prevent newline injection attacks. The fix is consistent with the sanitization pattern already used for $GITHUB_ENV and $GITHUB_PATH writes at the bottom of the same file.

