# imGui (version 0.1.0 (2018-02-26))
## A plugin for Haxegon: http://www.haxegon.com

**imGui** is a simple immediate mode style gui plugin for Haxegon. **imGui** allows you to write simple GUI code that looks like this:

``` haxe
import haxegon.*;

class Main {
  function update(){
    if(Gui.button("click me")){
      trace("You clicked the button!");
    }
  }
}
```

For more information about the idea behind imgui systems, check out:
  - <a href="https://mollyrocket.com/861">Casey Muratori's introduction video</a>
  - <a href="https://github.com/ocornut/imgui">Ocornut's Dear ImGui, a major inspiration for this plugin</a>
  - <a href="http://sol.gfxile.net/imgui/">Sol on Immediate Mode GUIs (IMGUI)</a>
  
This **imGui** plugin currently supports:
 - Automatic layouts of GUI elements
 - Buttons, Radio Buttons, Sliders and Scrollbars
 - Windows
 - Menubars
 
**imGui** is a work in progress. Stay tuned for more updates as Haxegon approaches 1.0!

## Setup

To install the **imGui** plugin, <a href="https://raw.githubusercontent.com/haxegon/plugin_imgui/master/plugins/Gui.hx">download this Gui.hx file</a>, and copy it into your own project's plugins folder.

## Usage

Here is another, more complex example:

``` haxe
import haxegon.*;

class Main{
  function init(){
    Gui.setfont("default", 3);
  }
	
  function update(){
    Gfx.clearscreen(Gui.style.shadow);
    
    Gui.window("Example window");
    
    switch(Gui.menubar(["File", "Edit"])){
      case "File":
        switch(Gui.menulist(["New", "Open", "Save", "Close"])){
          case "New":  		trace("New");
          case "Open":		trace("Open");
          case "Save":		trace("Save");
          case "Close":		trace("Close");
      }
      case "Edit":
        switch(Gui.menulist(["Undo", "", "Copy", "Paste"])){
          case "Undo": 		trace("Undo");
          case "Copy":		trace("Copy");
          case "Paste": 	trace("Paste");
      }
    }
	
    Gui.button("button");
    
    radioselected = Gui.radio("radio", radioselected);		
    
    sliderval = Gui.slider(160, 0, 100, sliderval);
      
    inputbox = Gui.input(inputbox);
      
    Gui.end();
  }	

  var radioselected:Bool = false;
  var sliderval:Float = 50;
  var inputbox:String = "type stuff here";
}
```

See <a href="https://github.com/haxegon/plugin_imgui/tree/master/examples">the examples folder</a> for more examples. 

## Documentation

Not available yet. Check back later! For now, refer to <a href="https://github.com/haxegon/plugin_imgui/tree/master/examples">the examples</a>. 

## About imGui

*version*: 0.1.0

*dependancies*: Haxegon 0.12.0 or newer.

*Targets*: **imGui** works on all current Haxegon targets - Native, HTML5 and Flash.

*Author*: @terrycavanagh

## About Haxegon

**imGui** is a plugin for Haxegon. For more plugins, see http://www.haxegon.com/plugins/

  
  
