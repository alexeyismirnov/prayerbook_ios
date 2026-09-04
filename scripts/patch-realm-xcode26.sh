#!/bin/bash
# Realm 10.52 / realm-core s2geometry specializes std::is_pod, which Xcode 26+ libc++ forbids.
# Patch SPM checkouts in DerivedData (and local build/) before compiling.

set -euo pipefail

patch_macros() {
  local macros="$1"
  [[ -f "$macros" ]] || return 0

  if ! grep -q 'struct is_pod' "$macros"; then
    return 0
  fi

  # SPM checkouts are often mode 444; force writable before editing.
  chmod u+w "$macros" 2>/dev/null || chmod +w "$macros" 2>/dev/null || true
  if [[ ! -w "$macros" ]]; then
    echo "warning: cannot write $macros (patch skipped)" >&2
    return 0
  fi

  python3 - "$macros" <<'PY'
import re, sys
from pathlib import Path
path = Path(sys.argv[1])
text = path.read_text()

# Replace whole DECLARE_POD / PROPAGATE macros (keep dummy typedefs so call sites still compile).
decl_pat = re.compile(
    r"#define DECLARE_POD\(TypeName\).*?"
    r"typedef int Dummy_Type_For_DECLARE_POD[^\n]*\n",
    re.S,
)
prop_pat = re.compile(
    r"#define PROPAGATE_POD_FROM_TEMPLATE_ARGUMENT\(TemplateName\).*?"
    r"typedef int Dummy_Type_For_PROPAGATE_POD_FROM_TEMPLATE_ARGUMENT[^\n]*\n",
    re.S,
)

decl_repl = (
    "#define DECLARE_POD(TypeName) /* is_pod specialization disabled for Xcode 26+ libc++ */ \\\n"
    "typedef int Dummy_Type_For_DECLARE_POD\n"
)
prop_repl = (
    "#define PROPAGATE_POD_FROM_TEMPLATE_ARGUMENT(TemplateName) /* disabled for Xcode 26+ */ \\\n"
    "typedef int Dummy_Type_For_PROPAGATE_POD_FROM_TEMPLATE_ARGUMENT\n"
)

text2, n1 = decl_pat.subn(decl_repl, text, count=1)
text3, n2 = prop_pat.subn(prop_repl, text2, count=1)

if n1 or n2:
    path.write_text(text3)
    print(f"Patched Realm s2 macros: {path} (DECLARE_POD={n1}, PROPAGATE={n2})")
else:
    print(f"No Realm is_pod macros to patch in {path}")
PY
}

# Typical Xcode DerivedData layout: $BUILD_DIR/../../SourcePackages/...
CANDIDATES=()
if [[ -n "${BUILD_DIR:-}" ]]; then
  CANDIDATES+=("${BUILD_DIR%/Build/*}/SourcePackages/checkouts/realm-core/src/external/s2/base/macros.h")
  CANDIDATES+=("${BUILD_DIR}/../../SourcePackages/checkouts/realm-core/src/external/s2/base/macros.h")
fi
if [[ -n "${SRCROOT:-}" ]]; then
  CANDIDATES+=("${SRCROOT}/build/SourcePackages/checkouts/realm-core/src/external/s2/base/macros.h")
fi
# Fallback: search nearby DerivedData for this project
while IFS= read -r f; do
  CANDIDATES+=("$f")
done < <(find "${HOME}/Library/Developer/Xcode/DerivedData" -path "*/prayerbook-*/SourcePackages/checkouts/realm-core/src/external/s2/base/macros.h" 2>/dev/null | head -5)

patched_any=0
if ((${#CANDIDATES[@]} > 0)); then
  for macros in "${CANDIDATES[@]}"; do
    if [[ -f "$macros" ]]; then
      patch_macros "$macros"
      patched_any=1
    fi
  done
fi

if [[ "$patched_any" -eq 0 ]]; then
  echo "note: realm-core macros.h not found yet (packages may still be resolving)"
fi
