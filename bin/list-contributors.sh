#!/bin/bash

set -eu -o pipefail

cat contributors.json | jq -r -s '
     flatten | map(.data.organization.teams.nodes) | flatten
     | map(select(.name | test("CF Volume Services|pks-bosh-lifecycle|haproxy-boshrelease") | not)) # filter teams
     | map(.name as $t | .repositories.nodes | map(.team = $t)                                      # add team field to repos
     | map(select((.isArchived | not))))                                                            # filter archived
     | flatten | sort_by(.url) | group_by(.url) | map(.[0]) | flatten                               # uniq on repo
     | map(select(.url | test("docs|cfcr|capi") | not))                                                  # exclude docs and cfcr
     | map({repo: .url, team: .team, commits: .defaultBranchRef.target.history.edges | map(.node)})
     | map(.commits = (.commits | map(select(.authoredDate | fromdate > now - 60*60*24*365))))
     | map(.repo as $r | .team as $t | .commits | map(.repo = $r | .team = $t)) | flatten
     | map(.author.user.url //= "https://github.com/" + (.author.email | split("@")[0]))
     | group_by(.author.user.url) | map(group_by(.repo))
     | map({author: .[0][0].author, contributions: map({repo: .[0].repo, contributions: . | length})})
     | map(.total = (.contributions | map(.contributions) | add))
     | sort_by(.total) | reverse
     | map(select(.author.name | test("ci|bot|metalink|team|cf bpm|builder|concourse";"i") | not))
'
