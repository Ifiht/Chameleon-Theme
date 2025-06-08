#!/usr/bin/env bash

INPUT="$1"
OUTPUT="$2"

if [[ -z "$INPUT" || -z "$OUTPUT" ]]; then
  echo "Usage: $0 input.icls output.icls"
  exit 1
fi

# Step 1: Remove parent_scheme="Darcula"
sed 's/\s*parent_scheme="Darcula"//' "$INPUT" > "$OUTPUT.tmp"

# Step 2: Remove empty <option> blocks and inherited-only definitions
# - <option name="..."/>
# - <option name="..." baseAttributes="..."/>
# - <option name="..."></option>
sed -i -E '/<option name="[^"]+"( baseAttributes="[^"]+")?\s*\/>/d' "$OUTPUT.tmp"
sed -i -E '/<option name="[^"]+"><\/option>/d' "$OUTPUT.tmp"

# Step 3: Remove full blocks with empty <value> sections (no child <option>)
# This is conservative: it only removes <option><value>...</value></option> if <value> has no child <option>
perl -0777 -pi -e '
  s{<option name="[^"]+">\s*<value>\s*</value>\s*</option>}{}g;
  s{<option name="[^"]+">\s*<value>\s*(<!--.*?-->\s*)*</value>\s*</option>}{}gs;
  s{<option name="[^"]+">\s*<value>\s*(?:<[^o]|<o(?!ption)).*?</value>\s*</option>}{}gs;
' "$OUTPUT.tmp"

# Final cleanup: remove extra blank lines
sed -i '/^\s*$/d' "$OUTPUT.tmp"

# Save final result
mv "$OUTPUT.tmp" "$OUTPUT"
echo "Cleaned theme saved to: $OUTPUT"