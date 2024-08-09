#!/bin/bash
# Telegram: https://t.me/blockchain_minter

show_usage() {
    cat << EOF
Usage: $0 <claim_reward_address> [options]

Description:
    This script queries verifier information for a specified claim_reward_address.

Arguments:
    <claim_reward_address>    The address to search for (required)

Options:
    -h, --help                Display this help message and exit
    -v, --verbose             Enable verbose output

More information: https://t.me/blockchain_minter
EOF
}

e() {
    echo -n "$1" | base64
}

d() {
    echo "$1" | base64 -d
}

# Initialize variables
verbose=false
search_address=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--verbose)
            verbose=true
            shift
            ;;
        *)
            if [[ -z $search_address ]]; then
                search_address="$1"
            else
                echo "Error: Invalid argument '$1'"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if search address is provided
if [[ -z $search_address ]]; then
    echo "Error: Missing claim_reward_address argument"
    show_usage
    exit 1
fi

# Output information if verbose mode is enabled
if $verbose; then
    echo "Searching for address: $search_address"
    echo "Fetching data from API..."
fi

response=$(curl -s 'https://api-testnet.prover.xyz/api/v1/verifier?pageNum=0&pageSize=1')
total=$(echo "$response" | grep -o '"total":[0-9]*' | sed 's/"total"://')
if [[ -z $total ]]; then
    echo "Error: Failed to get total count from API"
    exit 1
fi

if $verbose; then
    echo "Total number of verifiers: $total"
fi

# Use curl to get API data with the obtained total
json_response=$(curl -s "https://api-testnet.prover.xyz/api/v1/verifier?pageNum=0&pageSize=$total")

# Use sed to partially hide the user-provided address
hidden_search_address=$(echo "$search_address" | sed 's/^\(0x[0-9a-fA-F]\{3\}\)[0-9a-fA-F]*\([0-9a-fA-F]\{4\}\)$/\1*******\2/g')

# Escape special characters in the partially hidden address
escaped_hidden_search_address=$(echo "$hidden_search_address" | sed 's/[]\/$*.^[]/\\&/g')

# Use grep to find lines containing the partially hidden address
filtered_json=$(echo "$json_response" | grep -o "{[^}]*\"claim_reward_address\":\"$escaped_hidden_search_address\"[^}]*}")

# Exit script if no matching data is found
if [[ -z $filtered_json ]]; then
    echo "No data found for claim_reward_address: $search_address"
    exit 1
fi

# Split the filtered JSON into an array, with each element representing a matched item
IFS=$'\n' read -d '' -r -a matched_items <<< "$filtered_json"

# Output results
echo "Found ${#matched_items[@]} matching item(s) for address: $search_address"
# Iterate over the matched items and extract the required fields
for item in "${matched_items[@]}"; do
    id=$(echo "$item" | sed 's/.*"ID":\([^,]*\).*/\1/')
    name=$(echo "$item" | sed 's/.*"name":"\([^"]*\)".*/\1/')
    description=$(echo "$item" | sed 's/.*"description":"\([^"]*\)".*/\1/')
    status=$(echo "$item" | sed 's/.*"status":\([^,}]*\).*/\1/')
    address=$(echo "$item" | sed 's/.*"claim_reward_address":"\([^"]*\)".*/\1/')

    echo
    echo "- ID: $id"
    echo "- Name: $name"
    echo "- Description: $description"
    if [ "$status" -eq 1 ]; then
        echo "- Status: Accept"
    else
        echo "- Status: Pending"
    fi
    echo "- Address: $search_address"
    echo "- Details: https://testnet.cysic.xyz/m/dashboard/verifier/$id"
    echo
done

# Output additional information if verbose mode is enabled
if $verbose; then
    echo "Completed"
fi
