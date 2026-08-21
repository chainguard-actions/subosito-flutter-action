<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.21.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.21.0** was hardened automatically. 17 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Set action inputs' run: block in action.yaml directly interpolates multiple ${{ inputs.* }} expressions into shell commands. Most are single-quoted, but ${{ inputs.channel }} is completely unquoted at the end of the command line (e.g. `$GITHUB_ACTION_PATH/setup.sh -p \ ... ${{ inputs.channel }}`), allowing an attacker-controlled value to inject arbitrary shell arguments or commands. Even the single-quoted values are expanded by the YAML template engine before the shell sees them, so a value containing a single-quote can break out of the quoting. All ${{ ... }} expressions must be moved to env: vars and then properly double-quoted in the script.

Locations:

- `action.yaml:107`

### script-injection (severity: high)

Sub-rule (a): The 'Run setup script' run: block in action.yaml directly interpolates ${{ steps.flutter-action.outputs.VERSION }}, ${{ steps.flutter-action.outputs.ARCHITECTURE }}, ${{ steps.flutter-action.outputs.CACHE-PATH }}, ${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}, and — critically unquoted — ${{ steps.flutter-action.outputs.CHANNEL }} into the shell command. These step outputs are derived from user-supplied inputs and must not be interpolated directly into run: scripts. The unquoted ${{ steps.flutter-action.outputs.CHANNEL }} is especially dangerous as it allows shell word-splitting and glob expansion.

Locations:

- `action.yaml:128`

### script-injection (severity: high)

Sub-rule (a): The 'Echo outputs' run: block in .github/workflows/workflow.yaml directly interpolates ${{ runner.os }}, ${{ runner.arch }}, ${{ steps.flutter-action.outputs.CACHE-PATH }}, ${{ steps.flutter-action.outputs.CACHE-KEY }}, ${{ steps.flutter-action.outputs.CHANNEL }}, ${{ steps.flutter-action.outputs.VERSION }}, and ${{ steps.flutter-action.outputs.ARCHITECTURE }} into shell echo commands. Any ${{ ... }} expression inside a run: block is a script-injection risk regardless of the context it reads from. These should be passed via env: vars and referenced as double-quoted shell variables.

Locations:

- `.github/workflows/workflow.yaml:46`

### github-env-injection (severity: high)

setup.sh writes the variables $CACHE_PATH and $PUB_CACHE to $GITHUB_ENV, and $CACHE_PATH and $PUB_CACHE to $GITHUB_PATH, without applying the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). These variables are derived from user-controlled inputs passed via the -c, -d, and -g flags from action.yaml's run: blocks (e.g. inputs.cache-path, inputs.pub-cache-path, inputs.git-source). A newline embedded in any of these values would allow injection of arbitrary environment variables or PATH entries into the runner environment.

Locations:

- `setup.sh:218`
- `setup.sh:224`

### github-env-injection (severity: high)

setup.sh writes CHANNEL, VERSION, ARCHITECTURE, CACHE-KEY, CACHE-PATH, PUB-CACHE-KEY, and PUB-CACHE-PATH to $GITHUB_OUTPUT without sanitization. These values are derived from user-controlled inputs (channel, flutter-version, architecture, cache-key, cache-path, pub-cache-key, pub-cache-path). A newline in any value would allow injection of additional output variables, potentially overwriting downstream step outputs.

Locations:

- `setup.sh:199`

### unpinned-uses (severity: high)

action.yaml references actions/cache@v4 (a mutable version tag, not a full 40-character commit SHA) in two composite action steps. A tag can be moved to point to a different — potentially malicious — commit at any time, creating a supply-chain risk. Both occurrences should be pinned to a full SHA, e.g. actions/cache@1bd1e32a3bdc45362d1e726936510720a7c6158d # v4.

Locations:

- `action.yaml:113`
- `action.yaml:119`

### unpinned-uses (severity: high)

workflow.yaml references the following actions by mutable tag or branch rather than a full 40-character commit SHA: (1) actions/checkout@v4 — used in multiple jobs; (2) ludeeus/action-shellcheck@master — pinned to a branch name, which is especially dangerous as any commit pushed to master will be executed. All uses: references must be pinned to a full SHA digest.

Locations:

- `.github/workflows/workflow.yaml:19`
- `.github/workflows/workflow.yaml:21`
- `.github/workflows/workflow.yaml:37`
- `.github/workflows/workflow.yaml:79`
- `.github/workflows/workflow.yaml:95`
- `.github/workflows/workflow.yaml:107`

### missing-permissions (severity: medium)

workflow.yaml has no top-level permissions: key and none of its jobs (lint_shellcheck, test_channel, test_cache, test_version_file, test_print_output_x64, test_print_output_arm64) define a permissions: block. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad (write access to contents, pull-requests, etc.). A top-level `permissions: {}` or minimal per-job permissions should be added.

Locations:

- `.github/workflows/workflow.yaml:1`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:107`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version-file }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:108`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.architecture }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:109`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:110`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:111`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:112`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:113`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.git-source }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:114`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.channel }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:115`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions, static-inline-injection

**Notes:**

Fixed all findings across action.yaml, setup.sh, and .github/workflows/workflow.yaml:

1. action.yaml - 'Set action inputs' step: Moved all ${{ inputs.* }} expressions (flutter-version, flutter-version-file, architecture, cache-key, cache-path, pub-cache-key, pub-cache-path, git-source, channel) to env: block; referenced as double-quoted shell variables in run: block.

2. action.yaml - 'Run setup script' step: Moved all ${{ steps.flutter-action.outputs.* }} expressions (VERSION, ARCHITECTURE, CACHE-PATH, PUB-CACHE-PATH, CHANNEL) to env: block; referenced as double-quoted shell variables.

3. action.yaml - Pinned both actions/cache@v4 to actions/cache@0057852bfaa89a56745cba8c7296529d2fc39830 # v4.

4. setup.sh - Sanitized all values written to $GITHUB_OUTPUT using printf '%s' "$VAR" | tr -d '\n\r' to prevent newline injection.

5. setup.sh - Sanitized CACHE_PATH and PUB_CACHE values written to $GITHUB_ENV and $GITHUB_PATH using printf '%s' "$VAR" | tr -d '\n\r'.

6. workflow.yaml - Added top-level 'permissions: {}' block.

7. workflow.yaml - Pinned all actions/checkout@v4 to actions/checkout@11d5960a326750d5838078e36cf38b85af677262 # v4 (6 occurrences across all jobs).

8. workflow.yaml - Pinned ludeeus/action-shellcheck@master to ludeeus/action-shellcheck@00b27aa7cb85167568cb48a3838b75f4265f2bca # master.

9. workflow.yaml - 'Echo outputs' step: Moved all ${{ runner.* }} and ${{ steps.flutter-action.outputs.* }} expressions to env: block; referenced as double-quoted shell variables.

