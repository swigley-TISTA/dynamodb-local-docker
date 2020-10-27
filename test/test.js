var assert = require('assert');
var AWS = require("aws-sdk");
var path = require('path');

require('dotenv').config();
console.log("Loading node envoronment: " + JSON.stringify(process.env.NODE_ENV));

AWS.config.update({
    region: process.env.AWS_REGION,
    endpoint: "http://" + process.env.DB_HOST + ":" + process.env.DB_PORT
});

var dynamo = new AWS.DynamoDB.DocumentClient();

describe('DynamoDB', function() {
    
  describe('query row count', function() {
    const expected = 2;
    var params = {
        TableName : "Weather"
    };

    it('should return 2 because there are two items', function() {
    dynamo.scan(params, function(err, data) {
        if (err) {
           console.log("Error! " + JSON.stringify(err));
           throw("Error querying dynamodb: " + JSON.stringify(err));
        } else {
            const actual = data.Count;
            assert.strictEqual(actual, expected);
        }
     });
    
     
    });
  });
  describe('query by key', function() {
        const expected = {
            "zip":38419,
            "windspeed":44,
            "humidity":0.45,
            "bar_pressure":42,
            "temp":79};

            var params = {
                TableName : "Weather",
                KeyConditionExpression: "#zip = :zip",
                ExpressionAttributeNames:{
                    "#zip": "zip"
                },
                ExpressionAttributeValues: {
                    ":zip": 38419
                }
            };

            it('should return one item.', function() {
                dynamo.query(params, function(err, data) {
                    if (err) {
                       console.error("Unable to add weather for location", loc.zip, ". Error JSON:", JSON.stringify(err, null, 2));
                       console.log("Error! " + JSON.stringify(err));
                       throw("Error querying dynamodb: " + JSON.stringify(err));
                    } else {
                        const actual = data.Items[0];
                        assert.deepStrictEqual(actual, expected);
                         
                    }
                 });
                
              });
            
            

        
   });

  
    
});