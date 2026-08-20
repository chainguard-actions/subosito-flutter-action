<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.23.0** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Set action inputs' run block in action.yaml directly interpolates multiple ${{ inputs.* }} expressions into shell commands before the shell ever sees them. All inputs — flutter-version, flutter-version-file, architecture, cache-key, cache-path, pub-cache-key, pub-cache-path, git-source — are wrapped in single quotes, but YAML template substitution happens before the shell, so a value containing a single quote (') can break out of the quoting context and inject arbitrary shell commands. Most critically, ${{ inputs.channel }} is passed completely unquoted as a positional argument, allowing direct shell metacharacter injection. Fix: route all inputs through env: variables and double-quote every shell expansion.

Locations:

- `action.yaml:100`

### script-injection (severity: high)

The 'Run setup script' run block in action.yaml directly interpolates ${{ steps.flutter-action.outputs.CHANNEL }} unquoted into the shell command line. Even the single-quoted step outputs (VERSION, ARCHITECTURE, CACHE-PATH, PUB-CACHE-PATH) are subject to YAML template substitution before the shell sees them, allowing quote-breaking injection. Fix: route all step outputs through env: variables and double-quote every shell expansion.

Locations:

- `action.yaml:121`

### script-injection (severity: high)

The 'Echo outputs' run block in .github/workflows/workflow.yaml directly interpolates ${{ runner.os }}, ${{ runner.arch }}, ${{ steps.flutter-action.outputs.CACHE-PATH }}, ${{ steps.flutter-action.outputs.CACHE-KEY }}, ${{ steps.flutter-action.outputs.CHANNEL }}, ${{ steps.flutter-action.outputs.VERSION }}, and ${{ steps.flutter-action.outputs.ARCHITECTURE }} directly into the shell command string. Any ${{ ... }} expression inside a run: block is a script-injection risk because YAML template substitution occurs before the shell parses the command. Fix: use env: variables and reference them as quoted $VAR inside the run: block.

Locations:

- `.github/workflows/workflow.yaml:44`
- `.github/workflows/workflow.yaml:113`

### github-env-injection (severity: high)

setup.sh writes user-controlled values to $GITHUB_ENV and $GITHUB_PATH without sanitization (no 'printf "%s" ... | tr -d "\n\r"' step). Specifically: (1) 'echo "FLUTTER_ROOT=$CACHE_PATH/flutter" >> $GITHUB_ENV' — $CACHE_PATH is derived from the inputs.cache-path input passed via -c flag; (2) 'echo "PUB_CACHE=$PUB_CACHE" >> $GITHUB_ENV' — $PUB_CACHE is derived from inputs.pub-cache-path; (3) three path entries written to $GITHUB_PATH are also derived from these same user-controlled values. A newline embedded in any of these values would allow an attacker to inject arbitrary environment variable assignments or path entries.

Locations:

- `setup.sh:163`
- `setup.sh:164`
- `setup.sh:168`
- `setup.sh:169`
- `setup.sh:170`

### unpinned-uses (severity: high)

action.yaml references actions/cache@v5 (twice) using a mutable version tag instead of a pinned 40-character commit SHA. A tag can be moved to point to a different, potentially malicious commit. Fix: pin to a full SHA, e.g. actions/cache@5a3ec84eff668545956fd18022155c47e93e2684 # v5.

Locations:

- `action.yaml:108`
- `action.yaml:115`

### unpinned-uses (severity: high)

workflow.yaml references two actions with mutable refs: (1) actions/checkout@v6 — used in every job, pinned to a version tag rather than a commit SHA; (2) ludeeus/action-shellcheck@master — pinned to the 'master' branch, which is the most dangerous form of unpinned reference as it tracks the latest commit on that branch. Fix: pin both to full 40-character commit SHAs.

Locations:

- `.github/workflows/workflow.yaml:19`
- `.github/workflows/workflow.yaml:21`

### missing-permissions (severity: medium)

workflow.yaml has no top-level 'permissions:' key and none of its jobs (lint_shellcheck, test_channel, test_cache, test_version_file, test_master_version, test_print_output_x64, test_print_output_arm64) define a job-level 'permissions:' block. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad (write access to contents, pull-requests, etc.). Fix: add 'permissions: {}' or a minimal set of specific permissions at the top level.

Locations:

- `.github/workflows/workflow.yaml:1`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:111`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version-file }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:112`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.architecture }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:113`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:114`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:115`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:116`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:117`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.git-source }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:118`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.channel }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:119`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions, static-inline-injection

**Notes:**

Fixed all findings across action.yaml, setup.sh, and .github/workflows/workflow.yaml:

1. action.yaml - 'Set action inputs' step: Moved all 9 ${{ inputs.* }} expressions (flutter-version, flutter-version-file, architecture, cache-key, cache-path, pub-cache-key, pub-cache-path, git-source, channel) into an env: block. The channel input was previously completely unquoted; it's now double-quoted as "$INPUT_CHANNEL".

2. action.yaml - 'Run setup script' step: Moved all 5 ${{ steps.flutter-action.outputs.* }} expressions (VERSION, ARCHITECTURE, CACHE-PATH, PUB-CACHE-PATH, CHANNEL) into an env: block with double-quoted shell references.

3. action.yaml - Pinned both actions/cache@v5 references to full SHA caa296126883cff596d87d8935842f9db880ef25.

4. setup.sh - Fixed github-env-injection: sanitized FLUTTER_ROOT, PUB_CACHE written to $GITHUB_ENV and the three path entries written to $GITHUB_PATH using 'printf "%s" "$VAR" | tr -d "\n\r"' to strip embedded newlines.

5. workflow.yaml - Added 'permissions: {}' at top level.

6. workflow.yaml - Pinned actions/checkout@v6 to d23441a48e516b6c34aea4fa41551a30e30af803 in all 7 jobs (lint_shellcheck, test_channel, test_cache, test_version_file, test_master_version, test_print_output_x64, test_print_output_arm64).

7. workflow.yaml - Pinned ludeeus/action-shellcheck@master to 00b27aa7cb85167568cb48a3838b75f4265f2bca.

8. workflow.yaml - Fixed 'Echo outputs' steps in test_channel and test_master_version jobs by moving all ${{ runner.* }} and ${{ steps.flutter-action.outputs.* }} expressions into env: blocks.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the PRINT_ONLY block in setup.sh that writes to $GITHUB_OUTPUT. Replaced all 7 plain `echo "KEY=$value"` statements with `printf 'KEY=%s\n' "$(printf '%s' "$value" | tr -d '\n\r')"` to sanitize newlines from user-controlled values (info_channel, info_version, info_architecture, CACHE_KEY, CACHE_PATH, PUB_CACHE_KEY, PUB_CACHE) before writing them to $GITHUB_OUTPUT. The $GITHUB_ENV and $GITHUB_PATH writes at the end of the file were already correctly sanitized and were left unchanged.

