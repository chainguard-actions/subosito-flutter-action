<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.23.0** was hardened automatically. 12 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Two `run:` blocks in action.yaml directly interpolate `${{ ... }}` expressions into shell command strings, enabling script injection. The 'Set action inputs' step interpolates nine user-controlled inputs directly into shell arguments: `${{ inputs.flutter-version }}`, `${{ inputs.flutter-version-file }}`, `${{ inputs.architecture }}`, `${{ inputs.cache-key }}`, `${{ inputs.cache-path }}`, `${{ inputs.pub-cache-key }}`, `${{ inputs.pub-cache-path }}`, `${{ inputs.git-source }}`, and (unquoted) `${{ inputs.channel }}`. The 'Run setup script' step interpolates `${{ steps.flutter-action.outputs.VERSION }}`, `${{ steps.flutter-action.outputs.ARCHITECTURE }}`, `${{ steps.flutter-action.outputs.CACHE-PATH }}`, `${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}`, and (unquoted) `${{ steps.flutter-action.outputs.CHANNEL }}`. All of these are YAML-template-substituted before the shell sees them, allowing an attacker to inject arbitrary shell commands via crafted input values. The unquoted `${{ inputs.channel }}` and `${{ steps.flutter-action.outputs.CHANNEL }}` are especially dangerous as they are not even single-quoted.

Locations:

- `action.yaml:109`
- `action.yaml:136`

### unpinned-uses (severity: high)

Two `uses:` references in action.yaml use the mutable tag `@v5` instead of a pinned 40-character commit SHA. This exposes the action to supply-chain attacks if the upstream action tag is moved or compromised. Affected references: `actions/cache@v5` (Cache Flutter step) and `actions/cache@v5` (Cache pub dependencies step). These should be pinned to a full SHA, e.g. `actions/cache@1bd1e32a3bdc45362d1e726936510720a7c6158d # v4`.

Locations:

- `action.yaml:121`
- `action.yaml:128`

### github-env-injection (severity: high)

In setup.sh, values derived from user-controlled inputs (passed as shell arguments from `${{ inputs.* }}` expressions in action.yaml) are written to `$GITHUB_OUTPUT`, `$GITHUB_ENV`, and `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). Specifically: (1) `CHANNEL`, `VERSION`, `ARCHITECTURE`, `CACHE-KEY`, `CACHE-PATH`, `PUB-CACHE-KEY`, and `PUB-CACHE-PATH` are echoed directly to `${GITHUB_OUTPUT}` — these values are derived from user-supplied `inputs.channel`, `inputs.flutter-version`, `inputs.architecture`, `inputs.cache-key`, `inputs.cache-path`, `inputs.pub-cache-key`, and `inputs.pub-cache-path`. (2) `FLUTTER_ROOT` and `PUB_CACHE` are echoed directly to `${GITHUB_ENV}`. (3) Flutter bin paths are echoed directly to `${GITHUB_PATH}`. An attacker can inject newlines into these values to set arbitrary environment variables or paths in the calling workflow.

Locations:

- `setup.sh:214`
- `setup.sh:228`
- `setup.sh:234`

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

**Fixes applied:** script-injection, static-inline-injection, unpinned-uses, github-env-injection

**Notes:**

Fixed all findings in action.yaml and setup.sh:
1. script-injection / static-inline-injection (action.yaml lines 109, 136 / action.yml lines 111-119): Moved all nine ${{ inputs.* }} expressions in 'Set action inputs' step and all five ${{ steps.flutter-action.outputs.* }} expressions in 'Run setup script' step into env: blocks. Shell script now references them as plain env vars ($INPUT_FLUTTER_VERSION, $INPUT_CHANNEL, $STEP_VERSION, $STEP_CHANNEL, etc.).
2. unpinned-uses (action.yaml lines 121, 128): Pinned both `actions/cache@v5` references to full SHA `actions/cache@caa296126883cff596d87d8935842f9db880ef25 # v5`.
3. github-env-injection (setup.sh lines 214, 228, 234): Replaced all `echo "KEY=$VALUE"` writes to $GITHUB_OUTPUT, $GITHUB_ENV, and $GITHUB_PATH with `printf '%s' "$VALUE" | tr -d '\n\r'` sanitized forms to prevent newline injection.

