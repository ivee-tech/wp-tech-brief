const express = require("express");
const app = express();
let appInsights = require("applicationinsights");
appInsights.setup().start(); // Will use APPINSIGHTS_INSTRUMENTATIONKEY value
appInsights.defaultClient.addTelemetryProcessor((envelope) => {
  envelope.tags["ai.cloud.role"] = "MT3G-Step2-NodeJS";
});
var aiclient = appInsights.defaultClient;

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

const port = process.env.PORT || 3000; // For troubleshooting only
var server = app.listen(port, function () {
  const ai = process.env.APPINSIGHTS_INSTRUMENTATIONKEY || "0";
  if (ai != "0") {
    console.log("Sending telemetry to AI: " + ai);
  }
  console.log("Started on PORT: " + port);
});

const failureRate = process.env.FAILURE_RATE || 0;

app.post("/api/calculations", (request, response) => {
  console.log("Got a Post request: " + JSON.stringify(request.body));
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
  console.log("Generated data: " + JSON.stringify(data));
  aiclient.trackEvent({
    name: "Performed Gateway Calc Step 2",
    properties: {
      data: JSON.stringify(data),
    },
  });
  response.status(200).send(data);
});
