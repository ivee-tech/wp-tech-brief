using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MathTrickCore
{
    public class MathTrickException : Exception
    {
        public string CalcStep { get; set; }
        public string CalcStepName { get; set; }
        public string CalcErrorMessage { get; set; }        
    }
}
