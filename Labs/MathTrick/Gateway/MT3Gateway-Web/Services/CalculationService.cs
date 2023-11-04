using MathTrick3Web.Models;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;

namespace MathTrick3Web.Services
{
    public class CalculationService : ICalculationService
    {
        private readonly IConfiguration _configuration;
        private readonly RestApiHelper _restApiHelper;
        private readonly string _mt3CalcStep1Endpoint;

        public CalculationService(IConfiguration configuration,
                                  RestApiHelper restApiHelper)
        {
            _configuration = configuration;
            _restApiHelper = restApiHelper;
            _mt3CalcStep1Endpoint = _configuration["MT3GatewayAPIEndpoint"];
        }

        public List<CalculationStepModel> PerformMathTrick3Calculations(
               int pickedNumber, 
               IEnumerable<string> btkHeader)
        {
            var results = new List<CalculationStepModel>();
            try
            {
                string uri = $"api/calculations/{pickedNumber}";
                var fullUri = $"{_mt3CalcStep1Endpoint}/{uri}";
                results.AddRange(_restApiHelper.MakeGETCall(fullUri, "0", btkHeader));
                return results;
            }
            catch (Exception ex)
            {
                results.Add(new CalculationStepModel()
                {
                    CalcStep = "0",
                    CalcPerformed = "MT3Gateway-Web",
                    CalcResult = $"Exception: {ex.Message}"
                });
                return results;
            }
        }
    }
}
