const express = require("express");
const app = express();
const axios = require("axios");
axios.defaults.headers.post["Content-Type"] = "application/json";

let appInsights = require("applicationinsights");
let ai = process.env.APPINSIGHTS_INSTRUMENTATIONKEY || "0";
if (ai != "0") {
  appInsights.setup().start(); // Will use APPINSIGHTS_INSTRUMENTATIONKEY value
  appInsights.defaultClient.addTelemetryProcessor((envelope) => {
    envelope.tags["ai.cloud.role"] = "MT3C-Step2-NodeJS";
  });
  var aiclient = appInsights.defaultClient;
}
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

const port = process.env.PORT || 3000; // For troubleshooting only
var server = app.listen(port, function () {
  if (ai != "0") {
    console.log("Sending telemetry to AI: " + ai);
  }
  console.log("Started on PORT: " + port);
});

const failureRate = process.env.FAILURE_RATE || 0;

function callNextStep(originalResponse, pickedNumber, currentResult, nextStep) {
  nextStep += "/api/calculations";
  console.log("Calling Step 3: " + nextStep);
  axios
    .post(nextStep, {
      pickedNumber: pickedNumber,
      currentResult: currentResult,
    })
    .then((res) => {
      var returnData = res.data;
      console.log("Got a Response from Step 3: " + JSON.stringify(returnData));
      returnData.forEach((element) => {
        dataList.push(element);
      });
      console.log(
        "Complete response to original request: " + JSON.stringify(dataList)
      );
      originalResponse.status(200).send(dataList);
    })
    .catch((error) => {
      console.log("Got an Error from Step 3: " + error);
      var data = {
        calcPlatform: "NodeJS",
        calcStep: "2",
        calcPerformed: "MT3Chained-Step2-NodeJS",
        calcResult: `Exception: ${error.message}`,
      };
      dataList.push(data);
      originalResponse.status(200).send(dataList);
    });
}

var dataList = [];

app.post("/api/calculations", (request, response) => {
  // try {
    console.log("Got a Post request: " + JSON.stringify(request.body));
    dataList = [];
    if (Math.random() < failureRate / 100.0) {
      throw new Error("Some Random Error from Node.js");
    }
    var req = request.body;
    // Perform current step
    // Step 2 - Add 9 to result
    let pickedNumber = Number(req.pickedNumber);
    let currentResult = Number(req.currentResult);
    let addend = Number(process.env.CalcStepVariable) || 9;
    let previousResult = currentResult;
    currentResult = currentResult + addend;
    var data = {
      calcPlatform: "NodeJS",
      calcStep: "2",
      calcPerformed: `${previousResult} + ${addend}`,
      calcResult: currentResult.toString(),
    };
    dataList.push(data);
    console.log("Generated data: " + JSON.stringify(data));
    if (ai != "0") {
      aiclient.trackEvent({
        name: "Performed Chained Calc Step 2",
        properties: {
          data: JSON.stringify(data),
        },
      });
    }

    // Call next step if endpoint defined
    let nextStep = process.env.NextStepEndpoint || "";
    if (nextStep == "") {
      data = {
        calcPlatform: "NodeJS",
        calcStep: "Final",
        calcResult: currentResult.toString(),
      };
      dataList.push(data);
      console.log("Generated final data: " + JSON.stringify(data));
      response.status(200).send(dataList);
    } else {
      callNextStep(response, pickedNumber, currentResult, nextStep);
    }
  // } catch (e) {
  //   var data = {
  //     calcPlatform: "NodeJS",
  //     calcStep: "2",
  //     calcPerformed: "MT3Chained-Step2-NodeJS",
  //     calcResult: `Exception: ${e.message}`,
  //   };
  //   console.log("Got an error: " + JSON.stringify(data));
  //   dataList.push(data);
  //   response.status(200).send(dataList);
  // }
});
