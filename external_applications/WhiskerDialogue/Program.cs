using Aspose.Cells;
using Aspose.Cells.Utility;
using Google.Cloud.Translation.V2;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using WhiskerDialogue.Models;

namespace WhiskerDialogue
{
  class Program
  {
    private static readonly string subscriptionKey = "86387a53aa7e4c75a7826d3added572b";
    private static readonly string endpoint = "https://api.cognitive.microsofttranslator.com/";

    // Folder where the excel dialogues are to save
    const string DIALOGUE_EXCEL_FOLDER = "dialogues-excel";
    public static bool config_translate_to_pt = false;

    static async Task Main(string[] args)
    {
      config_translate_to_pt = Convert.ToBoolean(ConfigurationManager.AppSettings.Get("TRANSLATE_TO_PT"));
      if (!Directory.Exists(DIALOGUE_EXCEL_FOLDER))
        Directory.CreateDirectory(DIALOGUE_EXCEL_FOLDER);

      if (args.Length == 0)
      {
        args = new string[] {
          System.Reflection.Assembly.GetEntryAssembly().Location,
        };
      }
      else if (args.Length == 1 && args[0].ToUpper().Equals("HELP"))
      {
        Console.WriteLine("Please add the path of the directory where the json dialogues exists when running in command prompt (if needed).");
        Console.WriteLine("If there are no input paths, it will search the directory where the application exists.");
        Console.WriteLine("Converted files will be saved in 'dialogues-excel' folder in the place where the application resides.");
        Console.WriteLine("If you want to translate the file to PT, you may change TRANSLATE_TO_PT value to 'true' in WhiskerDialogue.dll.config file.");

        return;
      }

      foreach (var path in args)
      {
        string directory = Path.GetDirectoryName(path);
        await ProcessDirectory(directory);
      }
    }

   
    // Process all files in the directory passed in, recurse on any directories
    // that are found, and process the files they contain.
    public static async Task ProcessDirectory(string targetDirectory)
    {
      // Process the list of files found in the directory.
      string[] fileEntries = Directory.GetFiles(targetDirectory, "*.json", SearchOption.AllDirectories);
      foreach (string path in fileEntries)
      {
        string file = Path.GetFileName(path);
        if (file.Contains("WhiskerDialogue"))
          continue;
        
        await ProcessFile(path);
      }
    }

    // Insert logic for processing found files here.
    public static async Task ProcessFile(string path)
    {
      Console.WriteLine("Processed file '{0}'.", path);
      FileInfo file = new FileInfo(path);
      string filename = file.Name.Split('.')[0];

      // Create a Workbook object
      Workbook workbook = new Workbook();
      Worksheet worksheet = workbook.Worksheets[0];

      // Read JSON File
      string jsonInput = File.ReadAllText(file.FullName);

      // Deserialized whole dialogue file to dynamic type
      dynamic whisker = JsonConvert.DeserializeObject(jsonInput);

      // Create a node list to store converted token value
      List<Node> nodes = new List<Node>();

      // Loop each of the nodes in the whisker dialogue then
      foreach (var token in whisker.Children())
      {
        Node node = JsonConvert.DeserializeObject<Node>(token.Value.ToString());
        node.id = token.Path;

        // We must only add the nodes that are not expression and jump and also not null
        if (!String.IsNullOrWhiteSpace(node.text) && !node.id.Contains("Expression") && !node.id.Contains("Jump"))
        {
          if (config_translate_to_pt)
            node.pt = await TranslateText(node.text);

          nodes.Add(node);
        }
      }

      // Convert it back to json string input to easily saved to excel file
      var jsonModifiedInput = JsonConvert.SerializeObject(nodes);

      // Set JsonLayoutOptions
      JsonLayoutOptions options = new JsonLayoutOptions();
      options.ArrayAsTable = true;

      // Import JSON Data
      JsonUtility.ImportData(jsonModifiedInput, worksheet.Cells, 0, 0, options);

      // Save Excel file
      workbook.Save($"{DIALOGUE_EXCEL_FOLDER}/{filename}.xlsx");
    }

    public static async Task<string> TranslateText(string input)
    {

      // Output languages are defined as parameters, input language detected.
      string route = "/translate?api-version=3.0&to=pt";

      object[] body = new object[] { new { Text = input } };
      var requestBody = JsonConvert.SerializeObject(body);

      using (var client = new HttpClient())
      using (var request = new HttpRequestMessage())
      {
        // Build the request.
        request.Method = HttpMethod.Post;
        request.RequestUri = new Uri(endpoint + route);
        request.Content = new StringContent(requestBody, Encoding.UTF8, "application/json");
        request.Headers.Add("Ocp-Apim-Subscription-Key", subscriptionKey);
        request.Headers.Add("Ocp-Apim-Subscription-Region", "global");

        // Send the request and get response.
        HttpResponseMessage response = await client.SendAsync(request).ConfigureAwait(false);
        // Read response as a string.
        string result = await response.Content.ReadAsStringAsync();
        List<TranslationResponse> tResponse = JsonConvert.DeserializeObject<List<TranslationResponse>>(result);

        //Console.WriteLine(tResponse[0].translations[0].text);
        return tResponse[0].translations[0].text;
      }
    }

  }
}

