import haxegon.*;

class Main{
	public static function init(){
		Gfx.resizescreen(0, 0);
		
		Gui.setfont("roboto", 24);
		
		colourcontrols = [true, false, false, false, false, false];
		
		shadow = Gui.style.shadow;
		border = Gui.style.border;
		button = Gui.style.button;
		highlight = Gui.style.highlight;
		activehighlight = Gui.style.activehighlight;
	}
	
	public static function updatestyle(){
		Gui.style.shadow = shadow;
		Gui.style.border = border;
		Gui.style.button = button;
		Gui.style.highlight = highlight;
		Gui.style.activehighlight = activehighlight;
	}
	
	public static var colourcontrols:Array<Bool>;
	
	public static function colourcontrol(col:Int):Int{
		var r:Int = Col.getred(col);
		var g:Int = Col.getgreen(col);
		var b:Int = Col.getblue(col);
		
		r = Std.int(Gui.slider(160, 0, 255, r));
		Gui.shift();
		r = Std.parseInt(Gui.input("" + r, 50));
		Gui.nextrow();
		
		g = Std.int(Gui.slider(160, 0, 255, g));
		Gui.shift(); 
		g = Std.parseInt(Gui.input("" + g, 50));
		Gui.nextrow();
		
		b = Std.int(Gui.slider(160, 0, 255, b));
		Gui.shift(); 
		b = Std.parseInt(Gui.input("" + b, 50));
		Gui.nextrow();
		
		col = Col.rgb(r, g, b);
		
		return col;
	}
	
	public static function drawpalette(x:Int, y:Int){
		Gfx.fillbox(x, y, 16, 16, shadow);
		Gfx.drawbox(x, y, 16, 16, 0);
		
		x += 24;
		Gfx.fillbox(x, y, 16, 16, border);
		Gfx.drawbox(x, y, 16, 16, 0);
		
		x += 24;
		Gfx.fillbox(x, y, 16, 16, button);
		Gfx.drawbox(x, y, 16, 16, 0);
		
		x += 24;
		Gfx.fillbox(x, y, 16, 16, highlight);
		Gfx.drawbox(x, y, 16, 16, 0);
		
		x += 24;
		Gfx.fillbox(x, y, 16, 16, activehighlight);
		Gfx.drawbox(x, y, 16, 16, 0);
	}
	
	public static function togglecontrol(t:Int){
		colourcontrols[t] = !colourcontrols[t];
		if (colourcontrols[t]){
			for (i in 0 ... colourcontrols.length){
				if(t != i) colourcontrols[i] = false;
			}
		}
	}
	
	public static function update(){
		Gfx.clearscreen(shadow);
		
		drawpalette(Gfx.screenwidthmid, 5);
		
		Gui.window("Gui Style Editor", 5, 5);
		  var updated:Bool = false;
			if (Gui.menuitem("shadow", 240)) togglecontrol(0);
			if (colourcontrols[0]){
				shadow = colourcontrol(shadow);
				updated = true;
			}
			
			if (Gui.menuitem("border", 240)) togglecontrol(1);
			if (colourcontrols[1]){
				border = colourcontrol(border);
				updated = true;
			}
			
			if (Gui.menuitem("button", 240)) togglecontrol(2);
			if (colourcontrols[2]){
				button = colourcontrol(button);
				updated = true;
			}
			
			if (Gui.menuitem("highlight", 240)) togglecontrol(3);
			if (colourcontrols[3]){
				highlight = colourcontrol(highlight);
				updated = true;
			}
			
			if (Gui.menuitem("activehighlight", 240)) togglecontrol(4);
			if (colourcontrols[4]){
				activehighlight = colourcontrol(activehighlight);
				updated = true;
			}
			
			if (updated){
				updatestyle();
			}
		Gui.end();
		
		Gui.window("Example window", Gfx.screenwidthmid, Text.CENTER);
			switch(Gui.menubar(["File", "Edit", "View"])){
				case "File":
					switch(Gui.menulist(["New", "Modify", "Open", "Save", "Save as...", "Close"])){
						case "New":  				trace("New");
						case "Modify":			trace("Modity");
						case "Open":				trace("Open");
						case "Save":				trace("Save");
						case "Save as...":  trace("Save as...");
						case "Close":			  trace("Close");
					}
				case "Edit":
					switch(Gui.menulist(["Undo", "Redo", "", "Cut", "Copy", "Paste", "Select All"])){
					case "Undo":				  trace("Undo");
					case "Redo":  			  trace("Redo");
					case "Cut": 				  trace("Cut");
					case "Copy":				  trace("Copy");
					case "Paste":  		    trace("Paste");
					case "Select All":    trace("Select All");
				}
			case "View":
				switch(Gui.menulist(["Full Screen", "Split View"])){
					case "Full Screen":	  trace("Full Screen");
					case "Split View":    trace("Split View");
				}
			}
			Gui.button("button");
			
			radioselected = Gui.radio("radio", radioselected);
			
			sliderval = Gui.slider(200, 0, 100, sliderval);
			
			inputbox = Gui.input(inputbox);
			
			Gui.moveto(280, 80);
			scrollbarval = Gui.scrollbar(180, 0, 100, scrollbarval);
			
		Gui.end();
	}
	
	public static var radioselected:Bool = false;
	public static var sliderval:Float = 50;
	public static var scrollbarval:Float = 50;
	public static var inputbox:String = "inputbox";
	
	public static var button:Int;
	public static var shadow:Int;
	public static var border:Int;
	public static var highlight:Int;
	public static var activehighlight:Int;
}