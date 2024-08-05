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

# Use grep to find lines containing the specified address
filtered_json=$(echo "$json_response" | grep -o "{[^}]*\"claim_reward_address\":\"$search_address\"[^}]*}")

# Exit script if no matching data is found
if [[ -z $filtered_json ]]; then
    echo "No data found for claim_reward_address: $search_address"
    exit 1
fi

# Extract required fields using sed
id=$(echo "$filtered_json" | sed 's/.*"ID":\([^,]*\).*/\1/')
name=$(echo "$filtered_json" | sed 's/.*"name":"\([^"]*\)".*/\1/')
description=$(echo "$filtered_json" | sed 's/.*"description":"\([^"]*\)".*/\1/')
status=$(echo "$filtered_json" | sed 's/.*"status":\([^,}]*\).*/\1/')
address=$(echo "$filtered_json" | sed 's/.*"claim_reward_address":"\([^"]*\)".*/\1/')

# Output results
echo 
echo "- ID: $id"
echo "- Name: $name"
echo "- Description: $description"
if [ "$status" -eq 1 ]; then
    echo "- Status: Accept"
else
    echo "- Status: Pending"
fi
echo "- Address: $address"
echo "- Details: https://testnet.cysic.xyz/m/dashboard/verifier/$id" 
echo 

# Output additional information if verbose mode is enabled
if $verbose; then
    echo "Completed"
fi
