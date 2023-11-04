using MathTrickCore.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Net.Http;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;
using System.Text;
using MathTrickCore;

namespace MathTrick3Step5.Services
{
    public class CalculationService : ICalculationService
    {
        private readonly IConfiguration _configuration;
        private readonly string _nextStep;
        private readonly RestApiHelper _restApiHelper;

        public CalculationService(IConfiguration configuration,
                                   RestApiHelper restApiHelper)
        {
            _configuration = configuration;
            _nextStep = _configuration["NextStepEndpoint"];
            _restApiHelper = restApiHelper;
        }

        public List<CalculationStepModel> CalculateStep(int pickedNumber, double currentResult)
        {
            var steps = new List<CalculationStepModel>();

            int failureRate = _configuration.GetValue<int>("FAILURE_RATE", 0);
            var rand = new Random();
            if (rand.NextDouble() < failureRate / 100.0)
            {
                throw new Exception("Some random problem occurred.");
            }
            // Perform current step
            // Step 5 - Subtract the original number from result.
            double previousResult = currentResult;
            currentResult = currentResult - pickedNumber;
            steps.Add(new CalculationStepModel()
            {
                CalcStep = "5",
                CalcPerformed = $"{previousResult} - {pickedNumber}",
                CalcResult = Convert.ToInt32(currentResult).ToString()
            });

            if (string.IsNullOrEmpty(_nextStep))
            {
                steps.Add(new CalculationStepModel()
                {
                    CalcStep = "Final",
                    CalcResult = Convert.ToInt32(currentResult).ToString()
                });
            }
            return steps;
        }
    }
}
