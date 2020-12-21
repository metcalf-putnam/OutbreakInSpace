using System.Collections.Generic;

namespace WhiskerDialogue.Models
{
  public class TranslationResponse
  {
    public DetectedLanguage detectedLanguage { get; set; }
    public List<Translation> translations { get; set; }
  }

  public class DetectedLanguage 
  {
    public string language { get; set; }
    public float score { get; set; }
  }

  public class Translation
  { 
    public string text { get; set; }
    public string to { get; set; }
  }
}
