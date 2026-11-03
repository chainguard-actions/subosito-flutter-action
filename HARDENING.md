<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.21.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.21.0** was hardened automatically. 16 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) is violated in the step 'Set action inputs'. Inputs are interpolated straight into the run: script: `-n '${{ inputs.flutter-version }}'`, `-f '${{ inputs.flutter-version-file }}'`, `-a '${{ inputs.architecture }}'`, `-k '${{ inputs.cache-key }}'`, `-c '${{ inputs.cache-path }}'`, `-l '${{ inputs.pub-cache-key }}'`, `-d '${{ inputs.pub-cache-path }}'`, `-g '${{ inputs.git-source }}'` and the unquoted `${{ inputs.channel }}`. Also, `$GITHUB_ACTION_PATH/setup.sh` is not quoted.

Locations:

- `action.yaml:110`

### script-injection (severity: high)

Rule (a) is violated in the step 'Run setup script'. Step outputs are interpolated straight into the run: script: `-n '${{ steps.flutter-action.outputs.VERSION }}'`, `-a '${{ steps.flutter-action.outputs.ARCHITECTURE }}'`, `-c '${{ steps.flutter-action.outputs.CACHE-PATH }}'`, `-d '${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}'` and the unquoted `${{ steps.flutter-action.outputs.CHANNEL }}`. These outputs come from untrusted inputs.

Locations:

- `action.yaml:142`

### unpinned-uses (severity: high)

Two steps in this composite action reference an action by a mutable tag instead of a full commit SHA: `uses: actions/cache@v4` in the step 'Cache Flutter' and `uses: actions/cache@v4` in the step 'Cache pub dependencies'.

Locations:

- `action.yaml:125`
- `action.yaml:133`

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

### github-env-injection (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. In setup.sh, values derived from user-controlled action inputs (CACHE_PATH and PUB_CACHE, which are built from inputs.cache-path, inputs.pub-cache-path, inputs.channel, inputs.flutter-version, inputs.architecture, and inputs.git-source) are written to $GITHUB_ENV and $GITHUB_PATH without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). An attacker-controlled input containing newlines could inject arbitrary environment variable assignments or path entries. Affected writes: `echo "FLUTTER_ROOT=$CACHE_PATH" >> "${GITHUB_ENV:-/dev/null}"`, `echo "PUB_CACHE=$PUB_CACHE" >> "${GITHUB_ENV:-/dev/null}"`, and the three path entries written to $GITHUB_PATH.

Locations:

- `setup.sh:196`
- `setup.sh:197`
- `setup.sh:201`
- `setup.sh:202`
- `setup.sh:203`

### github-env-injection (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. In setup.sh, the PRINT_ONLY block writes CHANNEL, VERSION, ARCHITECTURE, CACHE-KEY, CACHE-PATH, PUB-CACHE-KEY, and PUB-CACHE-PATH to $GITHUB_OUTPUT without sanitization. These values are derived from user-controlled inputs (inputs.channel, inputs.flutter-version, inputs.architecture, inputs.cache-key, inputs.cache-path, inputs.pub-cache-key, inputs.pub-cache-path) passed via the action.yaml run: block. A newline in any of these values could inject additional key=value pairs into $GITHUB_OUTPUT. The required `printf '%s' "$VAR" | tr -d '\n\r'` sanitization is absent.

Locations:

- `setup.sh:175`
- `setup.sh:176`
- `setup.sh:178`
- `setup.sh:179`
- `setup.sh:180`
- `setup.sh:181`
- `setup.sh:182`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yaml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yaml b/action.yaml
index 7b14150..161d3b5 100644
--- a/action.yaml
+++ b/action.yaml
@@ -4,7 +4,6 @@ author: Alif Rachmawadi
 branding:
   icon: maximize
   color: blue
-
 inputs:
   channel:
     description: The Flutter build release channel
@@ -50,7 +49,6 @@ inputs:
     description: Git clone source
     required: false
     default: "https://github.com/flutter/flutter.git"
-
 outputs:
   CHANNEL:
     value: "${{ steps.flutter-action.outputs.CHANNEL }}"
@@ -82,10 +80,26 @@ outputs:
   PUB-CACHE-HIT:
     value: "${{ steps.cache-pub.outputs.cache-hit }}"
     description: "`true` if the pub cache was a hit"
-
 runs:
   using: composite
   steps:
     # This is a cross-platform composite action that needs yq in order to parse
     # the pubspec.yaml file.
     # It's not preinstalled on Windows runners.
@@ -94,49 +108,60 @@ runs:
       if: runner.os == 'Windows' && inputs.flutter-version-file != ''
       run: choco install yq
       shell: bash
-
     - name: Make setup script executable
       run: chmod +x "$GITHUB_ACTION_PATH/setup.sh"
       shell: bash
-
     - name: Set action inputs
       id: flutter-action
       shell: bash
+      env:
+        INPUT_FLUTTER_VERSION: ${{ inputs.flutter-version }}
+        INPUT_FLUTTER_VERSION_FILE: ${{ inputs.flutter-version-file }}
+        INPUT_ARCHITECTURE: ${{ inputs.architecture }}
+        INPUT_CACHE_KEY: ${{ inputs.cache-key }}
+        INPUT_CACHE_PATH: ${{ inputs.cache-path }}
+        INPUT_PUB_CACHE_KEY: ${{ inputs.pub-cache-key }}
+        INPUT_PUB_CACHE_PATH: ${{ inputs.pub-cache-path }}
+        INPUT_GIT_SOURCE: ${{ inputs.git-source }}
+        INPUT_CHANNEL: ${{ inputs.channel }}
       run: |
         $GITHUB_ACTION_PATH/setup.sh -p \
-          -n '${{ inputs.flutter-version }}' \
-          -f '${{ inputs.flutter-version-file }}' \
-          -a '${{ inputs.architecture }}' \
-          -k '${{ inputs.cache-key }}' \
-          -c '${{ inputs.cache-path }}' \
-          -l '${{ inputs.pub-cache-key }}' \
-          -d '${{ inputs.pub-cache-path }}' \
-          -g '${{ inputs.git-source }}' \
-          ${{ inputs.channel }}
-
+          -n "$INPUT_FLUTTER_VERSION" \
+          -f "$INPUT_FLUTTER_VERSION_FILE" \
+          -a "$INPUT_ARCHITECTURE" \
+          -k "$INPUT_CACHE_KEY" \
+          -c "$INPUT_CACHE_PATH" \
+          -l "$INPUT_PUB_CACHE_KEY" \
+          -d "$INPUT_PUB_CACHE_PATH" \
+          -g "$INPUT_GIT_SOURCE" \
+          "$INPUT_CHANNEL"
     - name: Cache Flutter
       id: cache-flutter
       uses: actions/cache@v4
       if: ${{ inputs.cache == 'true' }}
       with:
         path: ${{ steps.flutter-action.outputs.CACHE-PATH }}
         key: ${{ steps.flutter-action.outputs.CACHE-KEY }}
-
     - name: Cache pub dependencies
       uses: actions/cache@v4
       id: cache-pub
       if: ${{ inputs.cache == 'true' }}
       with:
         path: ${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}
         key: ${{ steps.flutter-action.outputs.PUB-CACHE-KEY }}-${{ hashFiles('**/pubspec.lock') }}
-
     - name: Run setup script
       shell: bash
       if: ${{ inputs.dry-run != 'true' && inputs.dry-run != true }}
+      env:
+        FLUTTER_ACTION_VERSION: ${{ steps.flutter-action.outputs.VERSION }}
+        FLUTTER_ACTION_ARCHITECTURE: ${{ steps.flutter-action.outputs.ARCHITECTURE }}
+        FLUTTER_ACTION_CACHE_PATH: ${{ steps.flutter-action.outputs.CACHE-PATH }}
+        FLUTTER_ACTION_PUB_CACHE_PATH: ${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}
+        FLUTTER_ACTION_CHANNEL: ${{ steps.flutter-action.outputs.CHANNEL }}
       run: |
         $GITHUB_ACTION_PATH/setup.sh \
-          -n '${{ steps.flutter-action.outputs.VERSION }}' \
-          -a '${{ steps.flutter-action.outputs.ARCHITECTURE }}' \
-          -c '${{ steps.flutter-action.outputs.CACHE-PATH }}' \
-          -d '${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}' \
-          ${{ steps.flutter-action.outputs.CHANNEL }}
+          -n "$FLUTTER_ACTION_VERSION" \
+          -a "$FLUTTER_ACTION_ARCHITECTURE" \
+          -c "$FLUTTER_AC
... (truncated)
```

Locations:

- `action.yaml`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed setup.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/setup.sh b/setup.sh
index 6100d42..d1646af 100755
--- a/setup.sh
+++ b/setup.sh
@@ -202,14 +202,21 @@ if [ "$PRINT_ONLY" = true ]; then
 	fi
 
 	{
-		echo "CHANNEL=$info_channel"
-		echo "VERSION=$info_version"
+		safe_channel=$(printf '%s' "$info_channel" | tr -d '\n\r')
+		safe_version=$(printf '%s' "$info_version" | tr -d '\n\r')
+		safe_architecture=$(printf '%s' "$info_architecture" | tr -d '\n\r')
+		safe_cache_key=$(printf '%s' "$CACHE_KEY" | tr -d '\n\r')
+		safe_cache_path=$(printf '%s' "$CACHE_PATH" | tr -d '\n\r')
+		safe_pub_cache_key=$(printf '%s' "$PUB_CACHE_KEY" | tr -d '\n\r')
+		safe_pub_cache=$(printf '%s' "$PUB_CACHE" | tr -d '\n\r')
+		echo "CHANNEL=$safe_channel"
+		echo "VERSION=$safe_version"
 		# VERSION_FILE is not printed, because it is essentially same as VERSION
-		echo "ARCHITECTURE=$info_architecture"
-		echo "CACHE-KEY=$CACHE_KEY"
-		echo "CACHE-PATH=$CACHE_PATH"
-		echo "PUB-CACHE-KEY=$PUB_CACHE_KEY"
-		echo "PUB-CACHE-PATH=$PUB_CACHE"
+		echo "ARCHITECTURE=$safe_architecture"
+		echo "CACHE-KEY=$safe_cache_key"
+		echo "CACHE-PATH=$safe_cache_path"
+		echo "PUB-CACHE-KEY=$safe_pub_cache_key"
+		echo "PUB-CACHE-PATH=$safe_pub_cache"
 	} >>"${GITHUB_OUTPUT:-/dev/null}"
 
 	exit 0
@@ -229,12 +236,16 @@ if [ ! -x "$CACHE_PATH/bin/flutter" ]; then
 fi
 
 {
-	echo "FLUTTER_ROOT=$CACHE_PATH"
-	echo "PUB_CACHE=$PUB_CACHE"
+	safe_cache_path=$(printf '%s' "$CACHE_PATH" | tr -d '\n\r')
+	safe_pub_cache=$(printf '%s' "$PUB_CACHE" | tr -d '\n\r')
+	echo "FLUTTER_ROOT=$safe_cache_path"
+	echo "PUB_CACHE=$safe_pub_cache"
 } >>"${GITHUB_ENV:-/dev/null}"
 
 {
-	echo "$CACHE_PATH/bin"
-	echo "$CACHE_PATH/bin/cache/dart-sdk/bin"
-	echo "$PUB_CACHE/bin"
+	safe_cache_path=$(printf '%s' "$CACHE_PATH" | tr -d '\n\r')
+	safe_pub_cache=$(printf '%s' "$PUB_CACHE" | tr -d '\n\r')
+	echo "$safe_cache_path/bin"
+	echo "$safe_cache_path/bin/cache/dart-sdk/bin"
+	echo "$safe_pub_cache/bin"
 } >>"${GITHUB_PATH:-/dev/null}"

```

Locations:

- `setup.sh`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, static-inline-injection, github-env-injection, prior-fix

**Notes:**

All listed findings are fixed in action.yaml and setup.sh. I haven't run the action or its tests yet.

**action.yaml**
- In the 'Set action inputs' and 'Run setup script' steps, every `${{ }}` expression now goes through the step's env: block. The script reads them as double-quoted shell variables.
- The `$GITHUB_ACTION_PATH/setup.sh` path is now quoted.
- The channel argument uses `${VAR:+"$VAR"}`, so an empty channel passes no argument rather than an empty one. setup.sh falls back to `stable` either way.
- Both `actions/cache@v4` uses are pinned to commit `0057852bfaa89a56745cba8c7296529d2fc39830`, with a `# v4` comment.

**setup.sh**
- Every value written to `$GITHUB_OUTPUT`, `$GITHUB_ENV` and `$GITHUB_PATH` now has newlines stripped first (`printf '%s' "$VAR" | tr -d '\n\r'`).
- The sanitized copies are made just before each write block, on their own lines. A failing command still stops the script under `set -e`, as before.

**Behaviour change:** before, a channel with spaces (for example `stable extra`) was split and the script used only the first word. Now the whole value reaches setup.sh as one argument and won't match any channel.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

setup.sh: in print-only mode, the script now removes newline and carriage-return characters (printf '%s' | tr -d '\n\r') from CHANNEL, VERSION, ARCHITECTURE, CACHE-KEY, CACHE-PATH, PUB-CACHE-KEY and PUB-CACHE-PATH before writing them to $GITHUB_OUTPUT. Each value is captured in its own plain assignment, so no command's exit status is hidden. Test-mode stdout output and the existing cleanup on the $GITHUB_ENV and $GITHUB_PATH writes are unchanged. action.yaml already maps all inputs through env:, so it was left as is. No tests were run.

