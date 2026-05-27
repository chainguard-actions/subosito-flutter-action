# Hardening Report: subosito--flutter-action/v2.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `ff50f15e4b79bfbf764dafdfd2579175a6ea9771`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **subosito--flutter-action/v2.23.0** was hardened automatically. 12 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Set action inputs' run block in action.yaml directly interpolates attacker-controlled inputs expressions into the shell command without first assigning them to environment variables. Most critically, `${{ inputs.channel }}` is interpolated completely unquoted (no surrounding quotes at all), allowing arbitrary shell command injection. The other inputs (flutter-version, flutter-version-file, architecture, cache-key, cache-path, pub-cache-key, pub-cache-path, git-source) are single-quoted but still directly interpolated — a value containing a single quote can break out of the quoting and inject shell commands. All inputs.* values must be assigned to env vars and referenced as $ENV_VAR in the run block.

Locations:

- `action.yaml:100`

### github-env-injection (severity: high)

The 'Set action inputs' run block passes attacker-controlled `inputs.*` values (including the completely unquoted `${{ inputs.channel }}`) as arguments to setup.sh, which then writes derived values to $GITHUB_OUTPUT, $GITHUB_ENV, and $GITHUB_PATH without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker can inject newlines into inputs (especially the unquoted `inputs.channel`) to write arbitrary key=value pairs into the special environment files. In setup.sh, the writes to $GITHUB_OUTPUT (lines ~200-210), $GITHUB_ENV (lines ~240-243), and $GITHUB_PATH (lines ~245-249) all lack sanitization of the values derived from user-controlled inputs.

Locations:

- `action.yaml:100`
- `setup.sh:200`

### unpinned-uses (severity: high)

Two `uses:` references in action.yaml pin to the mutable tag `@v5` instead of a full 40-character commit SHA. This means the action could silently change if the tag is moved, enabling supply-chain attacks. Failing references: `actions/cache@v5` (Cache Flutter step) and `actions/cache@v5` (Cache pub dependencies step). These should be pinned to a full SHA, e.g. `actions/cache@1bd1e32a3bdc45362d1e726936510720a7c6158d # v5`.

Locations:

- `action.yaml:112`
- `action.yaml:120`

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

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed all findings in action.yaml and setup.sh:
1. script-injection/static-inline-injection: Moved all ${{ inputs.* }} expressions in the 'Set action inputs' step to an env: block (INPUT_FLUTTER_VERSION, INPUT_FLUTTER_VERSION_FILE, INPUT_ARCHITECTURE, INPUT_CACHE_KEY, INPUT_CACHE_PATH, INPUT_PUB_CACHE_KEY, INPUT_PUB_CACHE_PATH, INPUT_GIT_SOURCE, INPUT_CHANNEL) and referenced them as $ENV_VAR with double-quoting in the shell script.
2. github-env-injection: In setup.sh, sanitized all user-controlled values written to $GITHUB_OUTPUT (lines ~200-210), $GITHUB_ENV (~240-243), and $GITHUB_PATH (~245-249) using `printf '%s' "$VAR" | tr -d '\n\r'` before writing.
3. unpinned-uses: Pinned both `actions/cache@v5` references to full SHA `actions/cache@27d5ce7f107fe9357f9df03efb73ab90386fccae # v5`.

