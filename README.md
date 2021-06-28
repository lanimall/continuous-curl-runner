# continuous-curl-runner

A simple runner to execute curl requests from a list of possible requests

# Build the image

```
docker-compose build
```

# Run

```
REQUESTS_JSON=$(cat sample-requests.json) docker-compose up  
```