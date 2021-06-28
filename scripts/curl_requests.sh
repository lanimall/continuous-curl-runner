#!/bin/sh

requests_length=$(echo $REQUESTS_JSON | jq -r '. | length')
requests_encoded=$(echo $REQUESTS_JSON | jq -r '.[] | @base64')

_jq() {
    echo ${1} | base64 -d | jq -r ${2}
}

CURL_OPTIONS="--write-out '%{http_code}' --silent --show-error --output /dev/null"

if [ "$SELECTION" == "random" ]; then
    index=`echo "$RANDOM % $requests_length + 1" | bc`
    pick=`echo $requests_encoded | cut -d" " -f $index`
    method=$(_jq $pick '.method')
    url=$(_jq $pick '.url')
    echo "Executing: curl $CURL_OPTIONS -X ${method} \"${url}\""
    curl $CURL_OPTIONS -X ${method} "${url}"
else
    for row in $requests_encoded; do
        method=$(_jq $row '.method')
        url=$(_jq $row '.url')
        echo "Executing: curl $CURL_OPTIONS -X ${method} \"${url}\""
        curl $CURL_OPTIONS -X ${method} "${url}"
    done
fi

echo ""
echo "Done!!"