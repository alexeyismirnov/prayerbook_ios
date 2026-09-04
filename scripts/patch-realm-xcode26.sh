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

  chmod u+w "$macros" 2>/dev/null || true
  python3 - "$macros" <<'PY'
import re, sys
from pathlib import Path
path = Path(sys.argv[1])
text = path.read_text()
# Strip forbidden std::is_pod specializations (Xcode 26+ libc++).
text, n1 = re.subn(
    r"(#define DECLARE_POD\(TypeName\)\s*\\\n)"
    r"namespace std \{\s*\\\n"
    r"template<> struct is_pod<TypeName> : true_type \{ \}; \\\n"
    r"\} \s*\\\n",
    r"\1// Disabled for Xcode 26+ libc++\n",
    text,
    count=1,
)
text, n2 = re.subn(
    r"(#define PROPAGATE_POD_FROM_TEMPLATE_ARGUMENT\(TemplateName\)\s*\\\n)"
    r"namespace std \{\s*\\\n"
    r"template <typename T> struct is_pod<TemplateName<T> > : std::is_trivial<T> \{ \}; \\\n"
    r"\} \s*\\\n",
    r"\1// Disabled for Xcode 26+ libc++\n",
    text,
    count=1,
)
if n1 or n2:
    path.write_text(text)
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
