using MathTrickCore.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MathTrick3Gateway.Services
{
    public interface ICalculationService
    {
        List<CalculationStepModel> CallCalculateSteps(int pickedNumber);
    }
}
