# DynamoDB Local Instance Docker Image

A docker image to launch a local insance of DynamoDB.  Based on the AWS documentation [Deploying DynamoDB Locally on Your Computer](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html).

Includes the following as examples:
* Use of dynamoDB in local mode for a development environment
* Dotenv configuration for local testing and deployed environment management
* Nodejs scripts for table/data administration
* Mocha unit tests
* Terraform module with terragrunt deployment scripts

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

```
### createTable.js

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

> npm run-script create-table

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


```
### weatherData.json

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



```
### loadWeatherData.js

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

> npm run-script load-data
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


Drop the table

```

    > npm run-script drop-table  
   
   dynamodb-local-docker@1.0.0 drop-table /Users/samwigley/Projects/github.com/swigley-TISTA/dynamodb-local-docker
   node deleteTable.js
   
   Deleted table. Table description JSON: {
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
       "CreationDateTime": "2020-10-27T21:48:18.648Z",
       "ProvisionedThroughput": {
         "LastIncreaseDateTime": "1970-01-01T00:00:00.000Z",
         "LastDecreaseDateTime": "1970-01-01T00:00:00.000Z",
         "NumberOfDecreasesToday": 0,
         "ReadCapacityUnits": 5,
         "WriteCapacityUnits": 5
       },
       "TableSizeBytes": 96,
       "ItemCount": 2,
       "TableArn": "arn:aws:dynamodb:ddblocal:000000000000:table/Weather"
     }
   }

```

## Deploying to AWS with Terraform

First create a copy of account.hcl.examle called account.acl, and add AWS account details to the variables.  Also update region.hcl and env.hcl if needed.

```

    locals {
      account_name   = "my-aws-account"
      aws_account_id = "1234567891011" 
      aws_profile    = "dev"
    }


```

Now change directory to the environment that you want to deploy and initialize terragrunt, reviewing the output from [terragrunt plan](https://terragrunt.gruntwork.io/docs/reference/cli-options/).

```

> cd terraform/stage/dynamodb
> terragrunt init
> terragrunt plan



Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v3.12.0...
- Installed hashicorp/aws v3.12.0 (signed by HashiCorp)

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, we recommend adding version constraints in a required_providers block
in your configuration, with the constraint strings suggested below.

* hashicorp/aws: version = "~> 3.12.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
[terragrunt] 2020/10/28 12:37:56 Running command: terraform plan
Acquiring state lock. This may take a few moments...
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.basic-dynamodb-table will be created
  + resource "aws_dynamodb_table" "basic-dynamodb-table" {
      + arn              = (known after apply)
      + billing_mode     = "PROVISIONED"
      + hash_key         = "zip"
      + id               = (known after apply)
      + name             = "Weather"
      + range_key        = "temp"
      + read_capacity    = 20
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Environment" = "prod"
          + "Name"        = "Weather"
        }
      + write_capacity   = 20

      + attribute {
          + name = "temp"
          + type = "N"
        }
      + attribute {
          + name = "zip"
          + type = "S"
        }

      + point_in_time_recovery {
          + enabled = (known after apply)
        }

      + server_side_encryption {
          + enabled     = (known after apply)
          + kms_key_arn = (known after apply)
        }

      + ttl {
          + attribute_name = "TimeToExist"
          + enabled        = false
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

```


Now review the output

```
> terraform apply
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.basic-dynamodb-table will be created
  + resource "aws_dynamodb_table" "basic-dynamodb-table" {
      + arn              = (known after apply)
      + billing_mode     = "PROVISIONED"
      + hash_key         = "zip"
      + id               = (known after apply)
      + name             = "Weather-stage"
      + range_key        = "temp"
      + read_capacity    = 20
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Environment" = "stage"
          + "Name"        = "Weather"
        }
      + write_capacity   = 20

      + attribute {
          + name = "temp"
          + type = "N"
        }
      + attribute {
          + name = "zip"
          + type = "S"
        }

      + point_in_time_recovery {
          + enabled = (known after apply)
        }

      + server_side_encryption {
          + enabled     = (known after apply)
          + kms_key_arn = (known after apply)
        }

      + ttl {
          + attribute_name = "TimeToExist"
          + enabled        = false
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_dynamodb_table.basic-dynamodb-table: Creating...
aws_dynamodb_table.basic-dynamodb-table: Creation complete after 7s [id=Weather-stage]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
Releasing state lock. This may take a few moments...

Outputs:

this_dynamodb_table_arn = arn:aws:dynamodb:us-east-2:357771246612:table/Weather-stage
this_dynamodb_table_id = Weather-stage
this_dynamodb_table_stream_arn = 
this_dynamodb_table_stream_label =

```
