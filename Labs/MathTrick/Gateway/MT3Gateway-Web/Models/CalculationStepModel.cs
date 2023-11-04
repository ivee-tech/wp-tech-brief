using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MathTrick3Web.Models
{
    public class CalculationStepModel
    {
        [JsonProperty("calcPlatform")]                       
        public string CalcPlatform { get; set; } = ".Net";

        [JsonProperty("calcStep")]
        public string CalcStep { get; set; }
        
        [JsonProperty("calcPerformed")]
        public string CalcPerformed { get; set; }

        [JsonProperty("calcResult")]
        public string CalcResult { get; set; }

        [JsonProperty("calcRetries")]
        public int CalcRetries { get; set; } = 0;

    }
}
