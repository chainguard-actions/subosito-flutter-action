<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.21.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.21.0** was hardened automatically. 14 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Set action inputs' run: block in action.yaml directly interpolates multiple ${{ inputs.* }} expressions into shell command strings. Most inputs are wrapped in single quotes (e.g., -n '${{ inputs.flutter-version }}'), but a single-quote in the input value would break out of the quoting and allow shell injection. Most critically, `${{ inputs.channel }}` is completely unquoted: `          ${{ inputs.channel }}` — an attacker-controlled value is passed directly to the shell with no quoting at all, enabling arbitrary command injection. All ${{ ... }} expressions must be moved to env: vars and then double-quoted in the shell script.

Locations:

- `action.yaml:96`

### script-injection (severity: high)

Sub-rule (a): The 'Run setup script' run: block in action.yaml directly interpolates ${{ steps.flutter-action.outputs.* }} expressions into shell command strings. The final argument `${{ steps.flutter-action.outputs.CHANNEL }}` is completely unquoted in the shell command, and the others are only single-quoted. Any ${{ ... }} expression inside a run: block is a script-injection risk regardless of the context it reads from. Offending line: `          ${{ steps.flutter-action.outputs.CHANNEL }}`

Locations:

- `action.yaml:124`

### github-env-injection (severity: high)

In setup.sh, values derived from user-controlled action inputs (CACHE_PATH and PUB_CACHE, which are built from inputs.cache-path, inputs.pub-cache-path, inputs.channel, inputs.flutter-version, inputs.architecture, and inputs.git-source) are written to $GITHUB_ENV and $GITHUB_PATH without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). An attacker-controlled input containing newlines could inject arbitrary environment variable assignments or path entries. Affected writes: `echo "FLUTTER_ROOT=$CACHE_PATH" >> "${GITHUB_ENV:-/dev/null}"`, `echo "PUB_CACHE=$PUB_CACHE" >> "${GITHUB_ENV:-/dev/null}"`, and the three path entries written to $GITHUB_PATH.

Locations:

- `setup.sh:196`
- `setup.sh:197`
- `setup.sh:201`
- `setup.sh:202`
- `setup.sh:203`

### github-env-injection (severity: high)

In setup.sh, the PRINT_ONLY block writes CHANNEL, VERSION, ARCHITECTURE, CACHE-KEY, CACHE-PATH, PUB-CACHE-KEY, and PUB-CACHE-PATH to $GITHUB_OUTPUT without sanitization. These values are derived from user-controlled inputs (inputs.channel, inputs.flutter-version, inputs.architecture, inputs.cache-key, inputs.cache-path, inputs.pub-cache-key, inputs.pub-cache-path) passed via the action.yaml run: block. A newline in any of these values could inject additional key=value pairs into $GITHUB_OUTPUT. The required `printf '%s' "$VAR" | tr -d '\n\r'` sanitization is absent.

Locations:

- `setup.sh:175`
- `setup.sh:176`
- `setup.sh:178`
- `setup.sh:179`
- `setup.sh:180`
- `setup.sh:181`
- `setup.sh:182`

### unpinned-uses (severity: high)

Two `uses:` references in action.yaml use the mutable tag `@v4` instead of a pinned 40-character SHA commit hash. This means the action could silently change if the tag is moved, enabling supply-chain attacks. Failing references: `actions/cache@v4` (used twice, for the Flutter SDK cache and the pub dependencies cache).

Locations:

- `action.yaml:109`
- `action.yaml:116`

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

**Fixes applied:** script-injection, static-inline-injection, unpinned-uses, github-env-injection

**Notes:**

Fixed all findings in action.yaml and setup.sh:

1. script-injection / static-inline-injection: Moved all ${{ inputs.* }} expressions in 'Set action inputs' step to an env: block (INPUT_FLUTTER_VERSION, INPUT_FLUTTER_VERSION_FILE, INPUT_ARCHITECTURE, INPUT_CACHE_KEY, INPUT_CACHE_PATH, INPUT_PUB_CACHE_KEY, INPUT_PUB_CACHE_PATH, INPUT_GIT_SOURCE, INPUT_CHANNEL). Replaced single-quoted interpolations with double-quoted env var references. The previously completely unquoted ${{ inputs.channel }} is now "$INPUT_CHANNEL". Similarly moved all ${{ steps.flutter-action.outputs.* }} expressions in 'Run setup script' to an env: block and double-quoted them.

2. unpinned-uses: Pinned both actions/cache@v4 references to full SHA actions/cache@0057852bfaa89a56745cba8c7296529d2fc39830 # v4.

3. github-env-injection (GITHUB_OUTPUT): In setup.sh PRINT_ONLY block, all 7 values (CHANNEL, VERSION, ARCHITECTURE, CACHE-KEY, CACHE-PATH, PUB-CACHE-KEY, PUB-CACHE-PATH) are now sanitized with printf '%s' "$VAR" | tr -d '\n\r' before writing to $GITHUB_OUTPUT.

4. github-env-injection (GITHUB_ENV/GITHUB_PATH): FLUTTER_ROOT, PUB_CACHE, and the three GITHUB_PATH entries are now sanitized with printf '%s' "$VAR" | tr -d '\n\r' before writing.

