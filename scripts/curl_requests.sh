#!/bin/sh

requests_length=$(echo $REQUESTS_JSON | jq -r '. | length')
requests_encoded=$(echo $REQUESTS_JSON | envsubst | jq -r '.[] | @base64')
CURL_OPTIONS="--write-out '%{http_code}' --silent --show-error --output /dev/null"

_jq() {
    echo "${1}" | base64 -d | jq -r "${2}"
}

_processRow(){
    local encoded_row=$1

    method=$(_jq $encoded_row '.method')
    url=$(_jq $encoded_row '.url')
    
    # headers
    headers_length=$(_jq $encoded_row 'try (.headers | length)')
    echo "Number of headers:$headers_length"
    headers_cmd=""
    if [[ "$headers_length" != "" && "$headers_length" != "0" ]]; then
        headers_cmd=$(_jq $encoded_row '.headers | to_entries | map("-H \(.key):\(.value|tostring)") | join(" ")')
    fi

    # basic_auth
    basic_auth_cmd=""
    basic_auth_cmd_nopwd=""
    basic_auth_user=$(_jq $encoded_row 'try (.basic_auth .username)')
    basic_auth_pwd=$(_jq $encoded_row 'try (.basic_auth .password)')
    if [[ "$basic_auth_user" != "null" && "$basic_auth_user" != ""  ]]; then
        basic_auth_cmd="-u $basic_auth_user:$basic_auth_pwd"
        basic_auth_cmd_nopwd="-u $basic_auth_user:************"
    fi

    echo "Executing: curl ${CURL_OPTIONS} -X ${method} ${basic_auth_cmd_nopwd} ${headers_cmd} \"${url}\""
    curl ${CURL_OPTIONS} -X ${method} ${basic_auth_cmd} ${headers_cmd} "${url}"
}

if [ "$REQUESTS_SELECTION" == "random" ]; then
    index=`echo "$RANDOM % $requests_length + 1" | bc`
    pick=`echo $requests_encoded | cut -d" " -f $index`
    _processRow $pick
elif [ "$REQUESTS_SELECTION" == "all" ]; then
    for row in $requests_encoded; do
        _processRow $row
    done
else
    echo "Unsupported request selection [$REQUESTS_SELECTION]"
fi

echo ""
echo "Done!!"