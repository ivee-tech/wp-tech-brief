﻿using MathTrickCore.Models;
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

namespace MathTrick3Step3.Services
{
    public class CalculationService : ICalculationService
    {
        private readonly IConfiguration _configuration;

        public CalculationService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public CalculationStepModel CalculateStep(int pickedNumber, double currentResult)
        {
            int failureRate = _configuration.GetValue<int>("FAILURE_RATE", 0);
            var rand = new Random();
            if (rand.NextDouble() < failureRate / 100.0)
            {
                throw new Exception("Some random problem occurred.");
            }
            // Perform current step
            // Step 3 - Subtract 3 from the result.
            int subtrahend = _configuration.GetValue<int>("CalcStepVariable", 3);
            double previousResult = currentResult;
            currentResult = currentResult - subtrahend;
            return new CalculationStepModel()
            {
                CalcStep = "3",
                CalcPerformed = $"{previousResult} - {subtrahend}",
                CalcResult = Convert.ToInt32(currentResult).ToString()
            };
        }
    }
}
