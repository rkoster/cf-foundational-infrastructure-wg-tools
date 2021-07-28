#!/bin/bash

set -eu -o pipefail

all=""
for org in cloudfoundry cloudfoundry-incubator; do
  for team in bosh credhub uaa bbr services postgres; do
    out=$(gh api graphql --paginate -f query="
      query(\$endCursor: String) {
	organization(login: \"${org}\") {
	  teams(first: 100, after: \$endCursor, query: \"${team}\") {
	    nodes {
	      repositories(first: 70) {
		nodes {
		  url
		  isArchived
		  defaultBranchRef {
		    target {
		      ... on Commit {
			history(first: 20) {
			  edges {
			    node {
			      abbreviatedOid
			      commitUrl
			      authoredDate
			      author {
				name
				email
				user {
				  name
				  url
				}
			      }
			    }
			  }
			}
		      }
		    }
		  }
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
echo ${all} | jq -r -s '.' > contributors.json
