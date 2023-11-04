using MathTrick3Web.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MathTrick3Web.Services
{
    public interface ICalculationService
    {
        List<CalculationStepModel> PerformMathTrick3Calculations(int pickedNumber, IEnumerable<string> btk);
    }
}
