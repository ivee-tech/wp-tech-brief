using MathTrick3Gateway.Services;
using MathTrickCore.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace MathTrick3Gateway.Controllers
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

        [HttpGet("{pickedNumber}")]
        public List<CalculationStepModel> Get(int pickedNumber)
        {
            try
            {
                return _calculationService.CallCalculateSteps(pickedNumber);
            }
            catch (Exception ex)
            {
                var steps = new List<CalculationStepModel>();
                steps.Add(new CalculationStepModel()
                {
                    CalcStep = "0",
                    CalcPerformed = "MT3Gateway-Gateway",
                    CalcResult = $"Exception: {ex.Message}"
                });
                return steps;
            }
        }     
    }
}
