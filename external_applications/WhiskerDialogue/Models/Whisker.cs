using System;
using System.Collections.Generic;
using System.Text;

namespace WhiskerDialogue.Models
{
  public class Whisker
  {
    public List<Node> dialogues { get; set; }
  }

  public class Node
  {
    public string id { get; set; }
    public string text { get; set; }
    public string pt { get; set; }
  }
}
