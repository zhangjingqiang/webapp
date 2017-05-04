# Execute Shell

## Command

```
#!/bin/sh

# create test environment
docker-compose -f docker-compose.test.yml build
docker-compose -f docker-compose.test.yml run --rm webapp_test

# check the last status code
if [ $? -eq 0 ]
then
    echo "All tests passed! :)"
else
    echo "Tests failed! :("
    exit 1
fi
```

# Execute Shell

## Command

```
#!/bin/bash
set -e

./ecs/deploy/push.sh && ./ecs/deploy/migrate.sh
```
