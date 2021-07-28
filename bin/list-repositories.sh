#!/bin/bash
all=""
for org in cloudfoundry cloudfoundry-incubator; do
  for team in bosh credhub uaa bbr services postgres; do
    out=$(gh api graphql --paginate -f query="
      query(\$endCursor: String) {
	organization(login: \"${org}\") {
	  teams(first: 100, after: \$endCursor, query: \"${team}\") {
	    nodes {
	      repositories {
		nodes {
		  url
		  isArchived
		}
	      }
	      name
	    }
	  }
	}
      }
    ")
    all="${all}${out}"
  done
done
echo ${all} | jq -r -s '
     map(.data.organization.teams.nodes) | flatten
     | map(.name as $t | .repositories.nodes | map(.team = $t) | map(select((.isArchived | not)))) | flatten
     | group_by(.url) | map({url: .[0].url, teams: map(.team)}) | flatten
     | map("- [\(.url | split("/")[3:5] | join("/"))](\(.url)): \(.teams | join(", "))") | sort | unique | .[]
' | grep -v -e 'CF Volume Services\|pks-bosh-lifecycle\|haproxy-boshrelease'
