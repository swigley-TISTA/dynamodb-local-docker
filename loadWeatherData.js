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
           console.error("Unable to add Location", loc.zip, ". Error JSON:", JSON.stringify(err, null, 2));
       } else {
           console.log("PutItem succeeded:", loc.zip);
       }
    });
});