#!/bin/bash

set -eu -o pipefail

./bin/list-contributors.sh  | jq -r '
  map(select(.total > 4))
  | to_entries | map((.value.author.user.url // "" | split("/")[3]) as $a
  | "## \(.key + 1) [\(.value.author.name)](\(.value.author.user.url)) (@\($a)) contributions: \(.value.total)
\(.value.contributions | map("- [\(.repo | split("/")[3:5] | join("/"))](\(.repo)/commits?author=\($a)) -> \(.contributions)") | join("\n"))") | .[]'
