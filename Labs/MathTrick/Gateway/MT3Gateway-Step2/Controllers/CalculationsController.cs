using MathTrick3Step2.Services;
using MathTrickCore.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace MathTrick3Step2.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CalculationsController : ControllerBase
    {
        private readonly ICalculationService _calculationService;

        public CalculationsController(ICalculationService calculationService)
        {
            _calculationService = calculationService;
        }

        [HttpPost]
        public CalculationStepModel Post([FromBody] JObject package)
        {
            int pickedNumber = Int32.Parse((string)package["pickedNumber"]);
            double currentResult = Double.Parse((string)package["currentResult"]);
            return _calculationService.CalculateStep(pickedNumber, currentResult);
        }
    }
}
