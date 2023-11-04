using MathTrickCore.Models;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace MathTrickCore
{
    public class RestApiHelper
    {
        private readonly IConfiguration _configuration;
        private readonly IHttpClientFactory _clientFactory;
        private readonly JsonSerializerOptions _jsonOptions;

        public RestApiHelper(IConfiguration configuration,
                             IHttpClientFactory clientFactory)
        {
            _configuration = configuration;
            _clientFactory = clientFactory;
            _jsonOptions = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true,
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            };
        }


        public CalculationStepModel MakePOSTCall(string uri, string body, string step)
        {            
            using var client = _clientFactory.CreateClient();           
            client.DefaultRequestHeaders.Add("Accept", "application/json");
            HttpContent content = new StringContent(body, Encoding.UTF8, "application/json");
            var response = client.PostAsync(uri, content).Result;
            if (response.IsSuccessStatusCode)
            {
                var data = response.Content.ReadAsStringAsync().Result;
                return JsonSerializer.Deserialize<CalculationStepModel>(data, _jsonOptions);
            }
            else
            {
                return new CalculationStepModel()
                {
                    CalcStep = step,
                    CalcPerformed = uri,
                    CalcResult = $"StatusCode: {(int)response.StatusCode}, ReasonPhrase: {response.ReasonPhrase}"
                };
            }
        }

        public List<CalculationStepModel> MakeNestedPOSTCall(string uri, string body, string step)
        {
            var results = new List<CalculationStepModel>();
            using var client = _clientFactory.CreateClient();
            client.DefaultRequestHeaders.Add("Accept", "application/json");
            HttpContent content = new StringContent(body, Encoding.UTF8, "application/json");
            var response = client.PostAsync(uri, content).Result;
            if (response.IsSuccessStatusCode)
            {
                var data = response.Content.ReadAsStringAsync().Result;
                results.AddRange(JsonSerializer.Deserialize<List<CalculationStepModel>>(data, _jsonOptions));
            }
            else
            {
                results.Add(new CalculationStepModel()
                {
                    CalcStep = step,
                    CalcPerformed = uri,
                    CalcResult = $"StatusCode: {(int)response.StatusCode}, ReasonPhrase: {response.ReasonPhrase}"
                });
            }
            return results;
        }

        public List<CalculationStepModel> MakeGETCall(string uri, string step, IEnumerable<string> btkHeader)
        {
            var results = new List<CalculationStepModel>();
            using var client = _clientFactory.CreateClient();
            client.DefaultRequestHeaders.Add("Accept", "application/json");
            if (btkHeader.Any())
            {
                client.DefaultRequestHeaders.Add("kubernetes-route-as", btkHeader);
            }
            var response = client.GetAsync(uri).Result;
            if (response.IsSuccessStatusCode)
            {
                var body = response.Content.ReadAsStringAsync().Result;
                results.AddRange(JsonSerializer.Deserialize<List<CalculationStepModel>>(body, _jsonOptions));
            }
            else
            {
                results.Add(new CalculationStepModel()
                {
                    CalcStep = step,
                    CalcPerformed = uri,
                    CalcResult = $"StatusCode: {(int)response.StatusCode}, ReasonPhrase: {response.ReasonPhrase}"
                });
            }
            return results;
        }
    }
}
