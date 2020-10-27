# DynamoDB Local Instance Docker Image

A docker image to launch a local insance of DynamoDB.  Based on the AWS documentation [Deploying DynamoDB Locally on Your Computer](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html).

**To install and run DynamoDB local with Docker Compose:**

1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop).



2. Run the following command-line:
    
     ``` 
     > docker-compose up

       Pulling dynamodb-local (amazon/dynamodb-local:latest)...
       latest: Pulling from amazon/dynamodb-local
       2cbe74538cb5: Pull complete
       9520313568bd: Pull complete
       ca0921fc7e3a: Pull complete
       32dad18454d4: Pull complete
       Digest: sha256:d03b77d09ac9fe26f98eed083bfec7b189ebbae2df213ee780b1632de17e9d3d
       Status: Downloaded newer image for amazon/dynamodb-local:latest
       Creating dynamodb-local ... done
       Attaching to dynamodb-local
       dynamodb-local    | Initializing DynamoDB Local with the following configuration:
       dynamodb-local    | Port:       8000
       dynamodb-local    | InMemory:   true
       dynamodb-local    | DbPath:     null
       dynamodb-local    | SharedDb:   false
       dynamodb-local    | shouldDelayTransientStatuses:       false
       dynamodb-local    | CorsParams: *
       dynamodb-local    | 
       dynamodb-local    | ERROR StatusLogger Log4j2 could not find a logging implementation. Please add        log4j-core to the classpath. Using SimpleLogger to log to the console...
            
     ```


## Using DynamoDB in Local mode

AWS documentation on how to use DynamoDB in local mode can be found in [Setting the Local Endpoint](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.UsageNotes.html#DynamoDBLocal.Endpoint).

```
    > aws dynamodb list-tables --endpoint-url http://localhost:8000

    {
        "TableNames": []
    }

```

### Using Local DynamoDB with node.js



Create a table.

createTable.js

```

    var AWS = require("aws-sdk");
    AWS.config.update({
      region: "us-east-2",
      endpoint: "http://localhost:8000"
    });
    var dynamodb = new AWS.DynamoDB();
    var params = {
        TableName : "Weather",
        KeySchema: [
            { AttributeName: "zip", KeyType: "HASH"},  //Partition key
        ],
        AttributeDefinitions: [
            { AttributeName: "zip", AttributeType: "N" },
        ],
        ProvisionedThroughput: {
            ReadCapacityUnits: 5,
            WriteCapacityUnits: 5
        }
    };
    dynamodb.createTable(params, function(err, data) {
        if (err) {
            console.error("Unable to create table. Error JSON:", JSON.stringify(err, null, 2));
        } else {
              console.log("Created table. Table description JSON:", JSON.stringify(data, null, 2));
          }
      });
```

Run the create table script.
```

> node createTable.js

Created table. Table description JSON: {
  "TableDescription": {
    "AttributeDefinitions": [
      {
        "AttributeName": "zip",
        "AttributeType": "N"
      }
    ],
    "TableName": "Weather",
    "KeySchema": [
      {
        "AttributeName": "zip",
        "KeyType": "HASH"
      }
    ],
    "TableStatus": "ACTIVE",
    "CreationDateTime": "2020-10-27T18:24:15.458Z",
    "ProvisionedThroughput": {
      "LastIncreaseDateTime": "1970-01-01T00:00:00.000Z",
      "LastDecreaseDateTime": "1970-01-01T00:00:00.000Z",
      "NumberOfDecreasesToday": 0,
      "ReadCapacityUnits": 5,
      "WriteCapacityUnits": 5
    },
    "TableSizeBytes": 0,
    "ItemCount": 0,
    "TableArn": "arn:aws:dynamodb:ddblocal:000000000000:table/Weather"
  }
}

```



Create some data.

weatherData.json
```

    [
      { "zip": 10110,
        "temp" : 89,
        "windspeed" : 10,    
        "humidity" : 0.75,
        "bar_pressure" : 22
      },
      { "zip": 38419,
        "temp" : 79,
        "windspeed" : 44,
        "humidity" : 0.45,
        "bar_pressure" : 42
      }
    ]

```


Write a script to load data.

loadWeatherData.js

```
var AWS = require("aws-sdk");
var fs = require('fs');

AWS.config.update({
    region: "us-east-2",
    endpoint: "http://localhost:8000"
});

var dynamo = new AWS.DynamoDB.DocumentClient();

console.log("Importing Weather into DynamoDB.");

var weather = JSON.parse(fs.readFileSync('weatherData.json', 'utf8'));

weather.forEach(function(loc) {
  console.log(loc)

    var params = {
        TableName: "Weather",
        Item: {
            "zip": loc.zip,
            "temp": loc.temp,
            "windspeed": loc.windspeed,
            "humidity": loc.humidity,
            "bar_pressure": loc.bar_pressure
        }
    };

    dynamo.put(params, function(err, data) {
       if (err) {
           console.error("Unable to add weather for location", loc.zip, ". Error JSON:", JSON.stringify(err, null, 2));
       } else {
           console.log("PutItem succeeded:", loc.zip);
       }
    });
});

```


Run the load data script.
```

> node loadWeatherData.js
Importing Weather into DynamoDB.
{
  zip: 10110,
  temp: 89,
  windspeed: 10,
  humidity: 0.75,
  bar_pressure: 22
}
{
  zip: 38419,
  temp: 79,
  windspeed: 44,
  humidity: 0.45,
  bar_pressure: 42
}
PutItem succeeded: 10110
PutItem succeeded: 38419


```

Running Mocha tests

```

> npm run-script test                   

 dynamodb-local-docker@1.0.0 test /Users/samwigley/Projects/github.com/swigley-TISTA/dynamodb-local-docker
 node_modules/mocha/bin/mocha test/test.js

Loading node envoronment: "development"


  DynamoDB
    query row count
      ✓ should return 2 because there are two items
    query by key
      ✓ should return one item.


  2 passing (29ms)

```