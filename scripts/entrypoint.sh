#!/bin/sh

#validate request json input
if [ "x$REQUESTS_JSON" == "x" ]; then
    echo "REQUESTS_JSON env is not set...nothing to do."
    exit 2;
fi

# check that REQUESTS_JSON has valid json
echo "$REQUESTS_JSON" | jq empty
isvalidreturn="$?"
if [ $isvalidreturn -gt 0 ]; then
    echo "REQUESTS_JSON array is not valid...nothing to do."
    exit $isvalidreturn;
fi

# make sure array is not empty
requests_length=$(echo "$REQUESTS_JSON" | jq -r '. | length')
if [ "$requests_length" == "0" ]; then
    echo "REQUESTS_JSON array is empty...nothing to do."
    exit 2;
fi
echo "REQUESTS_JSON array contains $requests_length elements! Ready to curl!"

if [ "x$LOOP" != "x" ]; then
   watch -n $LOOP /bin/sh curl_requests.sh
else
   /bin/sh curl_requests.sh
fi