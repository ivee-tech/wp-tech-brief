using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using MathTrickCore;
using MathTrickCore.Models;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;

namespace MathTrick3Gateway.Services {
    public class CalculationService : ICalculationService {
        private const int MAX_STEPS = 5;
        private readonly IConfiguration _configuration;
        private readonly string[] _calcSteps = new string[MAX_STEPS];
        private readonly int _retryCount;
        private readonly RestApiHelper _restApiHelper;

        public CalculationService (IConfiguration configuration,
            RestApiHelper restApiHelper) {
            _configuration = configuration;

            _calcSteps[0] = _configuration.GetValue<string> ("MT3GatewayStep1Endpoint");
            _calcSteps[1] = _configuration.GetValue<string> ("MT3GatewayStep2Endpoint");
            _calcSteps[2] = _configuration.GetValue<string> ("MT3GatewayStep3Endpoint");
            _calcSteps[3] = _configuration.GetValue<string> ("MT3GatewayStep4Endpoint");
            _calcSteps[4] = _configuration.GetValue<string> ("MT3GatewayStep5Endpoint");
            _retryCount = _configuration.GetValue<int> ("RETRIES", 3);
            _restApiHelper = restApiHelper;
        }

        public List<CalculationStepModel> CallCalculateSteps (int pickedNumber) {
            var steps = new List<CalculationStepModel> ();
            string currentResult = "0.0";
            int currentStep = 0;
            bool continueProcessing = true;
            string uri = $"api/calculations";
            int retries = 0;
            do {
                var fullUri = $"{_calcSteps[currentStep]}/{uri}";
                var package = new JObject (
                    new JProperty ("pickedNumber", pickedNumber.ToString ()),
                    new JProperty ("currentResult", currentResult));
                var results = _restApiHelper.MakePOSTCall (fullUri, package.ToString (Formatting.None), currentStep.ToString ());
                results.CalcRetries = retries;
                results.CalcStep = (currentStep + 1).ToString ();
                if (results.CalcResult.Contains ("Exception") ||
                    results.CalcResult.Contains ("StatusCode")) {
                    if (retries < _retryCount) {
                        retries++;
                    } else {
                        steps.Add (results);
                        continueProcessing = false;
                    }
                } else {
                    steps.Add (results);
                    currentStep++;
                    currentResult = results.CalcResult;
                    retries = 0;
                }

                if (currentStep == MAX_STEPS) {
                    steps.Add (new CalculationStepModel () {
                        CalcStep = "Final",
                            CalcResult = Convert.ToInt32 (currentResult).ToString ()
                    });
                }                
            } while (currentStep < MAX_STEPS && continueProcessing);
            return steps;
        }
    }
}