using MathTrickCore.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MathTrick3Step1.Services
{
    public interface ICalculationService
    {
        CalculationStepModel CalculateStep(int pickedNumber, double currentResult);
    }
}
