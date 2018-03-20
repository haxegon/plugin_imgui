//A very simple IMGUI style library for haxegon
import haxegon.*;
import starling.display.Image;
import starling.textures.RenderTexture;

private class GuiPrintCache{
	public function new(){
		volatile = false;
		imagecache = null;
		imagetexure = null;
		width = 0;
		halfwidth = 0;
		height = 0;
	}
	
	public var imagecache:Image;
	public var imagetexure:RenderTexture;
	public var text:String;
	public var volatile:Bool;
	public var width:Int;
	public var height:Int;
	public var halfwidth:Int;
}

private class GuiCache{
	public function new(){
		volatile = false;
	}
	
	public var width:Int;
	public var text:String;
	public var volatile:Bool;
}

private class GuiStyle{
	public function new(?_style:String){
		if (_style == null) _style = "dark";
		setstyle(_style);
	}
	
	public function setstyle(_style:String){
		switch(_style){
			case "dark":
				shadow = 0x161616;
				border = 0x595959;
				button = 0x7d7d7d;
				highlight = 0xb2b2b2;
				activehighlight = 0xd7d7d7;
				windowheader = 0x949494;
				textcol = 0xFFFFFF;
			case "darkblue":
				shadow = 0x07162b;
				border = 0x37485f;
				button = 0x546e8f;
				highlight = 0x96a9c1;
				activehighlight = 0xc5d2e2;
				windowheader = 0xa8b8cc;
				textcol = 0xFFFFFF;
			case "light":
				shadow = 0x404040;
				border = 0x909090;
				button = 0xc0c0c0;
				highlight = 0xd0d0d0;
				activehighlight = 0xe0e0e0;
				windowheader = 0xFFFFFF;
				textcol = 0x000000;
		}
	}
	public var button:Int;
	public var shadow:Int;
	public var border:Int;
	public var highlight:Int;
	public var activehighlight:Int;
	public var windowheader:Int;
	
	public var textcol:Int;
}

@:access(haxegon.Gfx)
@:access(Gui)
private class Rendercommandclass{
	public function new(){
		
	}
	
	public function setto(?_type:Int, ?_x:Float, ?_y:Float, ?_width:Float, ?_height:Float, ?_col:Int, ?_alpha:Float, ?_text:String, ?_font:String, ?_size:Float, ?_align:Int){
		type = _type;
		x = _x;
		y = _y;
		width = _width;
		height = _height;
		col = _col;
		alpha = _alpha;
		text = _text;
		font = _font;
		size = _size;
		align = _align;
		
		active = true;
	}
	
	public function draw(){
		if (active){
			switch(type){
				case 0: //fillbox
					Gfx.fillbox(x, y, width, height, col, alpha);
				case 1: //drawbox
					Gfx.drawbox(x, y, width, height, col, alpha);
				case 2: //print
					if (!Gui.guiprintcache.exists(text)){
						Text.font = font;
						Text.size = size;
						Text.align = Text.LEFT;
						
						Gui.tempprintcache = new GuiPrintCache();
						Gui.guiprintcache.set(text, Gui.tempprintcache);
						
						//Create the object
						Gui.tempprintcache.text = text;
						Gui.tempprintcache.width = Std.int(Text.width(text)) + 4;
						Gui.tempprintcache.halfwidth = Std.int(Gui.tempprintcache.width / 2);
						Gui.tempprintcache.height = Std.int(Gui.guisettings.textheight) + 4;
						Gui.tempprintcache.imagetexure = new RenderTexture(Gui.tempprintcache.width, Gui.tempprintcache.height, true);
						Gui.tempprintcache.imagecache = new Image(Gui.tempprintcache.imagetexure);
						
						//We release the screen, and store it in a temporary variable
						Gfx.screenshotdirty = true;
						Gfx.endmeshbatch();
						if (Gfx.drawto != null) Gfx.drawto.bundleunlock();
						var olddrawto:RenderTexture = Gfx.drawto;
						
						//We set the draw target to the render texture and set it up for rendering
						Gfx.drawto = Gui.tempprintcache.imagetexure;
						if (Gfx.drawto != null) Gfx.drawto.bundlelock();
						
						//We draw the text
						Text.display(2, 2, text, col, alpha);
						
						//And then we release it
						Gfx.endmeshbatch();
						if (Gfx.drawto != null) Gfx.drawto.bundleunlock();
						
						//Next, we restore the old screen layer
						Gfx.drawto = olddrawto;
						if (Gfx.drawto != null) Gfx.drawto.bundlelock();
					}
					
					Gui.tempprintcache = Gui.guiprintcache.get(text);
					if (Gui.tempprintcache != null){
						Gfx.endmeshbatch();
						Gfx.updatemeshbatch();
						Gfx.drawstate = Gfx.DRAWSTATE_IMAGE;
						
						Gfx.shapematrix.identity();
						Gfx.shapematrix.translate(Std.int(x - 2), Std.int(y - 2));
						if (align == Text.CENTER){
							Gfx.shapematrix.translate(-Std.int(Gui.tempprintcache.halfwidth), 0);
						}else if (align == Text.RIGHT){
							Gfx.shapematrix.translate(-Std.int(Gui.tempprintcache.width), 0);
						}
						Gfx.meshbatch.addMesh(Gui.tempprintcache.imagecache, Gfx.shapematrix, 1.0);
						Gfx.endmeshbatch();
					}
				case 3: //volatile print - for text that changes frequently
					//TO DO
			}
		}
	}
	
	private var type:Int;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var text:String;
	public var col:Int;
	public var alpha:Float;
	public var font:String;
	public var align:Int;
	public var size:Float;
	private var textfont:String;
	private var textalign:Int;
	private var textsize:Float;
	
	public var active:Bool;
}

@:access(haxegon.Text)
private class GuiSettings{
	public function new(_font:String, _size:Float){
		font = _font;
		size = _size;
		
		var textfont:String = Text.font;
		var textalign:Int = Text.align;
		var textsize:Float = Text.size;
		
		Text.setfont(font, size);
		textheight = Text.height("16LETTERS^@gyj_!");
		var textwidth:Float = Text.width("16LETTERSoftext!");
		
		buttonheight = Std.int(textheight * 1.8);
		buttonwidth = Std.int(textwidth * 1);
		buttonspacing = Std.int(textheight * 0.75);
		scrollbarwidth = Std.int(textheight);
		checkboxsize = Std.int(textheight);
		inputboxsize = Std.int(textheight * 1.2);
		
		Text.font = textfont;
		Text.align = textalign;
		Text.size = textsize;
		
		buttontextyoffset = Std.int((buttonheight / 2) - (textheight / 2));
		inboxboxtextyoffset = Std.int((inputboxsize / 2) - (textheight / 2));
	}
	
	public var buttonwidth:Int;
	public var buttonheight:Int;
	public var buttonspacing:Int;
	public var scrollbarwidth:Int;
	public var checkboxsize:Int;
	public var inputboxsize:Int;
	public var font:String;
	public var size:Float;
	public var textheight:Float;
	
	public var buttontextyoffset:Float;
	public var inboxboxtextyoffset:Float;
}

@:access(Gui)
@:access(haxegon.Text)
private class GuiWindow{
	public function new(){	}
	
	public function init(_x:Float, _y:Float, _id:String){
		id = _id;
		
		//Are we creating this window for the first time? Do a layout pass.
		if (Gui.guiwindowmemory.exists(id)){
			windowmemory = Gui.guiwindowmemory.get(id);
			windowmemory.layoutpass = false;
		}else{
		  windowmemory = {
				windowxoff: 0, windowyoff: 0, 
				boundaryx: 0, boundaryy: 0,
				boundaryw: 0, boundaryh: 0,
				newboundaryx: 0, newboundaryy: 0,
				newboundaryw: 0, newboundaryh: 0,
				layoutpass: true
			};
			Gui.guiwindowmemory.set(id, windowmemory);
		}
		
		x = windowmemory.boundaryx = _x;
		y = windowmemory.boundaryy = _y;
		windowmemory.newboundaryx = _x;
		windowmemory.newboundaryy = _y;
		windowmemory.newboundaryw = 0;
		windowmemory.newboundaryh = 0;
		
		boundaryspacing = Gui.guisettings.buttonspacing;
		
		active = true;
	}
	
	public function verticalmove(_xoff:Float, _yoff:Float){
		lastoffsetx = _xoff + Gui.guisettings.buttonspacing;
		lastoffsety = _yoff + Gui.guisettings.buttonspacing;
		
		y += lastoffsety;
	}
	
	public function horizontalmove(){
		y -= lastoffsety;
		x += lastoffsetx;
	}
	
	public function nextrow(){
		x = windowmemory.boundaryx + boundaryspacing;
	}
	
	public function fillbox(x:Float, y:Float, width:Float, height:Float, col:Int, alpha:Float = 1.0){
		if (lastrendercommand >= rendercommand.length) rendercommand.push(new Rendercommandclass());
		
		rendercommand[lastrendercommand].setto(0, x, y, width, height, col, alpha, "", "", 1, 0);
		
		lastrendercommand++;
		
		if(windowmemory.layoutpass){
			if (skipboundarycheck){
				skipboundarycheck = false;
			}else{
				updateboundary(x, y, width, height);
			}
		}
	}
	
	public function drawbox(x:Float, y:Float, width:Float, height:Float, col:Int, alpha:Float = 1.0){
		if (lastrendercommand >= rendercommand.length) rendercommand.push(new Rendercommandclass());
		
		rendercommand[lastrendercommand].setto(1, x, y, width, height, col, alpha, "", "", 1, 0);
		
		lastrendercommand++;
		
		if(windowmemory.layoutpass){
			if (skipboundarycheck){
				skipboundarycheck = false;
			}else{
				updateboundary(x, y, width, height);
			}
		}
	}
	
	public function textwidth(text:String, ?font:String, ?size:Float):Float{
		var returnval:Float;
		var textfont:String = Text.font;
		var textalign:Int = Text.align;
		var textsize:Float = Text.size;
		
		Text.font = (font == null)?Gui.guisettings.font:font;
		Text.size = (size == null)?Gui.guisettings.size:size;
		Text.align = Text.LEFT;
		
		returnval = Text.width(text);
		
		Text.font = textfont;
		Text.align = textalign;
		Text.size = textsize;
		
		return returnval;
	}
	
	public function print(x:Float, y:Float, text:String, ?col:Int, ?alpha:Float, ?font:String, ?size:Float, ?align:Int){
		if (lastrendercommand >= rendercommand.length) rendercommand.push(new Rendercommandclass());
		
		rendercommand[lastrendercommand].setto(2, x, y, 0, 0, (col == null)?0xFFFFFF:col, (alpha == null)?1.0:alpha, text, (font == null)?Gui.guisettings.font:font, (size == null)?Gui.guisettings.size:size, (align == null)?Text.LEFT:align);
		
		lastrendercommand++;
		
		if(windowmemory.layoutpass){
			if (skipboundarycheck){
				skipboundarycheck = false;
			}else{
				updateboundary(x, y, textwidth(text, font, size), Gui.guisettings.textheight);
			}
		}
	}
	
	public function updateboundary(_x:Float, _y:Float, _width:Float, _height:Float){
		if (_x < windowmemory.newboundaryx) windowmemory.newboundaryx = _x;
		if (_y < windowmemory.newboundaryy) windowmemory.newboundaryy = _y;
		if (_x + _width + boundaryspacing > windowmemory.newboundaryx + windowmemory.newboundaryw) windowmemory.newboundaryw = _x + _width + boundaryspacing - windowmemory.newboundaryx;
		if (_y + _height + boundaryspacing > windowmemory.newboundaryy + windowmemory.newboundaryh) windowmemory.newboundaryh = _y + _height + boundaryspacing - windowmemory.newboundaryy;
	}
	
	public function finishboundary(){
		windowmemory.boundaryx = windowmemory.newboundaryx;
		windowmemory.boundaryy = windowmemory.newboundaryy;
		windowmemory.boundaryw = windowmemory.newboundaryw;
		windowmemory.boundaryh = windowmemory.newboundaryh;
	}
	
	public var rendercommand:Array<Rendercommandclass> = [];
	public var lastrendercommand:Int = 0;
	
	public var boundaryspacing:Int;
	public var skipboundarycheck:Bool = false;
	
	public var x:Float;
	public var y:Float;
	public var type:Int;
	private var lastoffsetx:Float;
	private var lastoffsety:Float;
	
	public var active:Bool;
	public var id:String;
	public var windowmemory:Dynamic;
}

@:access(haxegon.Core)
@:access(haxegon.Text)
@:access(haxegon.Input)
class Gui{
	public static function hasfocus():Bool{
		return 
		  haskeyboardfocus != "" ||
			requestingkeyboardfocus != "" ||
			(activeitem != "" && activeitem != "-") ||
			mouseoverwindow();
	}
	
	private static function updateid(_elementtype:String, pos:haxe.PosInfos){
		if (!enabled) enable();
		id = windowlist[currentwindow].id + "|" + posid(pos);
		elementtype = _elementtype;
		_changed = false;
	}
	
	private static function checkactive(w:Float, h:Float){
		if (alignment == Text.LEFT){
			internalx = windowlist[currentwindow].x;
		}else if (alignment == Text.CENTER){
			internalx = windowlist[currentwindow].x - Std.int(w / 2);
		}else if (alignment == Text.RIGHT){
			internalx = windowlist[currentwindow].x - Std.int(w);
		}
		
		internaly = windowlist[currentwindow].y;
		windowlist[currentwindow].verticalmove(w, h);
		
		if (Geom.inbox(Mouse.x, Mouse.y, internalx, internaly, w, h)){
			hotitem = id;
			if (activeitem == "" && Mouse.leftheld()){
				activeitem = id;
			}
		}
	}
	
	public static function changed():Bool{
		return _changed;
	}
	private static var _changed:Bool = false;
	
	public static function scrollbar(height:Float, topvalue:Float, bottomvalue:Float, currentvalue:Float, ?pos:haxe.PosInfos):Float{
		updateid("scrollbar", pos);
		var cursorsize = guisettings.scrollbarwidth;
		checkactive(cursorsize, height);
		
		// Calculate mouse cursor's relative y offset
    var ypos = 1 + ((height - 2) - cursorsize) * Math.abs(topvalue - currentvalue) / (bottomvalue - topvalue);
		var returnvalue:Float = bottomvalue + ((topvalue - bottomvalue) * ((height - (Mouse.y - internaly)) / height));
		
		// Render the scrollbar
		var barwidth = (guisettings.scrollbarwidth / 10);
		windowlist[currentwindow].fillbox(internalx + (guisettings.scrollbarwidth / 2) - barwidth, internaly, barwidth * 2, height, style.shadow);
		
		if (activeitem == id || hotitem == id){
			windowlist[currentwindow].fillbox(internalx + 1, internaly + ypos, guisettings.scrollbarwidth - 2, cursorsize, style.activehighlight);
		}else{
			windowlist[currentwindow].fillbox(internalx + 1, internaly + ypos, guisettings.scrollbarwidth - 2, cursorsize, style.highlight);
		}
		
		if (activeitem == id){
			value = Geom.clamp(returnvalue, topvalue, bottomvalue);
			_changed = true;
			return value;
		}
		return currentvalue;
	}
	
	public static function slider(width:Float, leftvalue:Float, rightvalue:Float, currentvalue:Float, ?pos:haxe.PosInfos):Float{
		updateid("slider", pos);
		var cursorsize = guisettings.scrollbarwidth;
		checkactive(width, cursorsize);
		
		// Calculate mouse cursor's relative y offset
    var xpos = 1 + ((width - 2) - cursorsize) * Math.abs(leftvalue - currentvalue) / (rightvalue - leftvalue);
		var returnvalue:Float = rightvalue + ((leftvalue - rightvalue) * ((width - (Mouse.x - internalx)) / width));
		
		// Render the scrollbar
		var barheight = (guisettings.scrollbarwidth / 10);
		windowlist[currentwindow].fillbox(internalx, internaly + (guisettings.scrollbarwidth / 2) - barheight, width, (barheight * 2), style.shadow);
		
		if (activeitem == id || hotitem == id){
			windowlist[currentwindow].fillbox(internalx + xpos, internaly + 1, cursorsize, guisettings.scrollbarwidth - 2, style.activehighlight);
		}else{
			windowlist[currentwindow].fillbox(internalx + xpos, internaly + 1, cursorsize, guisettings.scrollbarwidth - 2, style.highlight);
		}
		
		if (activeitem == id){
			_changed = true;
			value = Geom.clamp(returnvalue, leftvalue, rightvalue);
			return value;
		}
		return currentvalue;
	}
	
	public static function indent(?distance:Int, ?pos:haxe.PosInfos){
		if (!enabled) enable();
		id = posid(pos);
		windowlist[currentwindow].x += (distance == null)?guisettings.buttonspacing:distance;
	}
	
	public static function unindent(?distance:Int, ?pos:haxe.PosInfos){
		if (!enabled) enable();
		id = posid(pos);
		windowlist[currentwindow].x -= (distance == null)?guisettings.buttonspacing:distance;
	}
	
	public static function text(label:String, ?pos:haxe.PosInfos){
		if (elementtype == "text"){
			windowlist[currentwindow].y -= guisettings.buttonspacing;
		}
		updateid("text", pos);
		internalx = windowlist[currentwindow].x;
		internaly = windowlist[currentwindow].y;
		Text.setfont(guisettings.font, guisettings.size);
		
		var textwidth:Float = -1;
		if (guitextlabelcache.exists(id)){
			var temp:GuiCache = guitextlabelcache.get(id);
			if (label == temp.text){
				textwidth = temp.width;
			}else{
				temp.volatile = true;
				textwidth = Text.width(label);
			}
		}
		
		if(textwidth == -1){
			textwidth = Text.width(label);
			
			var temp:GuiCache = new GuiCache();
			temp.text = label;
			temp.width = Std.int(textwidth);
		  guitextlabelcache.set(id, temp);
		}
		
		windowlist[currentwindow].verticalmove(textwidth, guisettings.textheight);
		
		windowlist[currentwindow].print(internalx, internaly, label, style.textcol);
	}
	
	public static function menulist(options:Array<String>, ?pos:haxe.PosInfos):String{
		//This is a shortcut helper
		//A menulist is a collection of label buttons, arranged in a window.
		//Therefore, this object itself doesn't need an ID
		
		var optionwidth:Float = 0;
		for (i in 0 ... options.length){
			var textwidth:Float = windowlist[currentwindow].textwidth(options[i]);
			if (textwidth >= optionwidth) optionwidth = textwidth;
		}
		optionwidth = (optionwidth * 1.5);
		
		window("", lastmenuxposition, windowlist[currentwindow].y - guisettings.buttonspacing, 0, pos);
		windowlist[currentwindow].type = 2;
		
		adjustposition(-guisettings.buttonspacing, -guisettings.buttonspacing);
		var returnval:String = "";
		for (i in 0 ... options.length){
			if (options[i] == ""){
				windowlist[currentwindow].fillbox(windowlist[currentwindow].x + (guisettings.buttonspacing / 4), windowlist[currentwindow].y + (guisettings.buttonspacing / 4), optionwidth - (guisettings.buttonspacing / 2), 2, style.button);
				adjustposition(0, guisettings.buttonspacing / 2);
			}else{
				if (menuitem(options[i], optionwidth, pos)){
					returnval = options[i];
					//Close the menu
					if (lastmenubar != null){
						lastmenubar.currentlyselected = -1;
					}
				}
			}
		}
		
		end();
		
		return returnval;
	}
	
	public static function menubar(options:Array<String>, ?pos:haxe.PosInfos):String{
		updateid("button", pos);
		//Not using checkactive here, because there are a bunch of different hotspots
		var w:Float = ((windowlist[currentwindow].type == 0)?(Gfx.screenwidth - windowlist[currentwindow].x + guisettings.buttonspacing):windowlist[currentwindow].windowmemory.boundaryw);
		var h:Float = guisettings.textheight;
		
		var menubarstate:Dynamic;
		
		if (guiwindowmemory.exists(id)){
			menubarstate = guiwindowmemory.get(id);
		}else{
			menubarstate = {
			  currentlyselected: -1
			}
			guiwindowmemory.set(id, menubarstate);
		}
		lastmenubar = menubarstate;
		
		//We want the menubar to be flush to the corner, so we remove the buttonspacing
		internalx = windowlist[currentwindow].x - guisettings.buttonspacing;
		internaly = windowlist[currentwindow].y - guisettings.buttonspacing;
		if (windowlist[currentwindow].type != 0){
			internaly -= guisettings.buttonspacing;
			windowlist[currentwindow].verticalmove(w, h - (guisettings.buttonspacing * 2));
		}else{
			windowlist[currentwindow].verticalmove(w, h - guisettings.buttonspacing);
		}
		
		if (Geom.inbox(Mouse.x, Mouse.y, internalx, internaly, w, h)){
			hotitem = id;
			if (activeitem == "" && Mouse.leftheld()){
				activeitem = id;
			}
		}
		
		var optionwidth:Float = 0;
		//TO DO: improve this one
		if (guimenubarcache.exists(id)){
			optionwidth = guimenubarcache.get(id).width;
		}else{
			for (i in 0 ... options.length){
				var textwidth:Float = windowlist[currentwindow].textwidth(options[i]);
				if (textwidth >= optionwidth) optionwidth = textwidth;
			}
		  optionwidth = (optionwidth * 2);
			
			var temp:GuiCache = new GuiCache();
			temp.width = Std.int(optionwidth);
			guimenubarcache.set(id, temp);
		}
		var activeoption:Int = -1;
		
		windowlist[currentwindow].skipboundarycheck = true;
		if (activeitem == id && hotitem == id){
			windowlist[currentwindow].fillbox(internalx, internaly, w, h, style.button);
			internalx += Std.int(guisettings.buttonspacing / 2);
			for (i in 0 ... options.length){
				var xp:Float = internalx + (i * optionwidth);
				if (Geom.inbox(Mouse.x, Mouse.y, xp, internaly, optionwidth, h)){
					windowlist[currentwindow].fillbox(xp, internaly, optionwidth, h, style.activehighlight);
					activeoption = i; lastmenuxposition = xp;
				}
				windowlist[currentwindow].print(xp + (optionwidth / 2), internaly, options[i], style.textcol, 1.0, guisettings.font, guisettings.size, Text.CENTER);
			}
		}else	if (hotitem == id || menubarstate.currentlyselected > -1){
			windowlist[currentwindow].fillbox(internalx, internaly, w, h, style.button);
			internalx += Std.int(guisettings.buttonspacing / 2);
			for (i in 0 ... options.length){
				var xp:Float = internalx + (i * optionwidth);
				if (Geom.inbox(Mouse.x, Mouse.y, xp, internaly, optionwidth, h) || menubarstate.currentlyselected == i){
					windowlist[currentwindow].fillbox(xp, internaly, optionwidth, h, style.highlight);
					activeoption = i;
				}
				windowlist[currentwindow].print(xp + (optionwidth / 2), internaly, options[i], style.textcol, 1.0, guisettings.font, guisettings.size, Text.CENTER);
			}
		}else{
			windowlist[currentwindow].fillbox(internalx, internaly, w, h, style.button);
			internalx += Std.int(guisettings.buttonspacing / 2);
			for (i in 0 ... options.length){
				windowlist[currentwindow].print(internalx + (i * optionwidth) + (optionwidth / 2), internaly, options[i], style.textcol, 1.0, guisettings.font, guisettings.size, Text.CENTER);
			}
		}
		
		if (options.length == 0) return "";
		
		if (Mouse.leftclick()){
			if (hotitem == id && activeitem == id){
				if (activeoption == -1){
					menubarstate.currentlyselected = -1;
					return "";
				}
				menubarstate.currentlyselected = activeoption;
				lastmenuxposition = windowlist[currentwindow].x - guisettings.buttonspacing + (menubarstate.currentlyselected * optionwidth) + Std.int(guisettings.buttonspacing / 2);
				return options[activeoption];
			}else{
				if (hotitem == "" && previoushotitem == ""){
					menubarstate.currentlyselected = -1;
					return "";
				}
				return options[menubarstate.currentlyselected];
			}
		}else if (menubarstate.currentlyselected > -1){
			lastmenuxposition = windowlist[currentwindow].x - guisettings.buttonspacing + (menubarstate.currentlyselected * optionwidth) + Std.int(guisettings.buttonspacing / 2);
			return options[menubarstate.currentlyselected];
		}
		return "";
	}
	
	public static function button(label:String, ?pos:haxe.PosInfos):Bool{
		updateid("button", pos);
		checkactive(guisettings.buttonwidth, guisettings.buttonheight);
		
		if (activeitem == id && hotitem == id){			
			windowlist[currentwindow].fillbox(internalx, internaly + 1, guisettings.buttonwidth, guisettings.buttonheight - 2, style.border);
			windowlist[currentwindow].fillbox(internalx + 1, internaly + 2, guisettings.buttonwidth - 2, guisettings.buttonheight - 4, style.activehighlight);
			windowlist[currentwindow].print(internalx + (guisettings.buttonwidth / 2), internaly + guisettings.buttontextyoffset, label, style.textcol, null, null, null, Text.CENTER);
			windowlist[currentwindow].fillbox(internalx, internaly + guisettings.buttonheight - 2, guisettings.buttonwidth, 2, style.border);
		}else	if (hotitem == id){
			windowlist[currentwindow].fillbox(internalx, internaly, guisettings.buttonwidth, guisettings.buttonheight, style.border);
			windowlist[currentwindow].fillbox(internalx + 1, internaly + 1, guisettings.buttonwidth - 2, guisettings.buttonheight - 4, style.highlight);
			windowlist[currentwindow].print(internalx + (guisettings.buttonwidth / 2), internaly + guisettings.buttontextyoffset - 1, label, style.textcol, null, null, null, Text.CENTER);
		}else{
			windowlist[currentwindow].fillbox(internalx, internaly, guisettings.buttonwidth, guisettings.buttonheight, style.border);
			windowlist[currentwindow].fillbox(internalx + 1, internaly + 1, guisettings.buttonwidth - 2, guisettings.buttonheight - 4, style.button);
			windowlist[currentwindow].print(internalx + (guisettings.buttonwidth / 2), internaly + guisettings.buttontextyoffset - 1, label, style.textcol, null, null, null, Text.CENTER);
		}
		
		if (debugmode){
			windowlist[currentwindow].skipboundarycheck = true;
			windowlist[currentwindow].fillbox(internalx, internaly, guisettings.buttonwidth, guisettings.buttonheight, Col.BLACK, 0.5);
			windowlist[currentwindow].skipboundarycheck = true;
			windowlist[currentwindow].print(internalx, internaly, id, Col.WHITE, 1, guisettings.font, Std.int(guisettings.size / 2));
		}
		
		if (Mouse.leftclick() && hotitem == id && activeitem == id){
			return true;
		}
    return false;
	}
	
	public static function password(inputlabel:String, ?customwidth:Int, ?pos:haxe.PosInfos):String{
		passwordmode = true;
		var result:String = input(inputlabel, customwidth);
		passwordmode = false;
		return result;
	}
	
	public static function input(inputlabel:String, ?customwidth:Int, ?pos:haxe.PosInfos):String{
		updateid("inputbox", pos);
		if (customwidth == null) customwidth = Std.int(guisettings.buttonwidth * 1.5);
		checkactive(customwidth, guisettings.inputboxsize);
		
		var labeldisplay:String = inputlabel;
		if (passwordmode){
			labeldisplay = "";
			for (i in 0 ... inputlabel.length) labeldisplay += "*";
		}
		
		if (haskeyboardfocus == id){
			labeldisplay = inputbuffer;
			if (passwordmode){
				labeldisplay = "";
				for (i in 0 ... inputbuffer.length) labeldisplay += "*";
			}
		
			windowlist[currentwindow].fillbox(internalx, internaly, customwidth, guisettings.inputboxsize, style.border);
			windowlist[currentwindow].drawbox(internalx, internaly, customwidth, guisettings.inputboxsize, style.activehighlight);
			if(flash.Lib.getTimer() % 400 > 200){
				windowlist[currentwindow].print(internalx + 3, internaly + guisettings.inboxboxtextyoffset, labeldisplay + "_", style.textcol);
			}else{
				windowlist[currentwindow].print(internalx + 3, internaly + guisettings.inboxboxtextyoffset, labeldisplay, style.textcol);
			}
		}else	if (activeitem == id && hotitem == id){
			windowlist[currentwindow].fillbox(internalx, internaly, customwidth, guisettings.inputboxsize, style.border);
			windowlist[currentwindow].drawbox(internalx, internaly, customwidth, guisettings.inputboxsize, style.activehighlight);
			windowlist[currentwindow].print(internalx + 3, internaly + guisettings.inboxboxtextyoffset, labeldisplay, style.textcol);
		}else	if (hotitem == id){			
			windowlist[currentwindow].fillbox(internalx, internaly, customwidth, guisettings.inputboxsize, style.border);
			windowlist[currentwindow].drawbox(internalx, internaly, customwidth, guisettings.inputboxsize, style.highlight);
			windowlist[currentwindow].print(internalx + 3, internaly + guisettings.inboxboxtextyoffset, labeldisplay, style.textcol);
		}else{
			windowlist[currentwindow].fillbox(internalx, internaly, customwidth, guisettings.inputboxsize, style.border);
			windowlist[currentwindow].drawbox(internalx, internaly, customwidth, guisettings.inputboxsize, style.button);
			windowlist[currentwindow].print(internalx + 3, internaly + guisettings.inboxboxtextyoffset, labeldisplay, style.textcol);
		}
		
		if (Input.justpressed(Key.TAB)){
			//Give keyboard focus to the next keyboard widget
			requestingkeyboardfocus = "-";
			Input.forcerelease(Key.TAB);
		}
		
		if ((requestingkeyboardfocus == id || requestingkeyboardfocus == "-") && haskeyboardfocus == ""){
			requestingkeyboardfocus = "";
			haskeyboardfocus = id;
			Text.inputbuffer = inputlabel;
			inputbuffer = Text.inputbuffer;
		}
		
		if (Mouse.leftclick() && hotitem == id && activeitem == id){
			if(haskeyboardfocus == ""){
				haskeyboardfocus = id;
				Text.inputbuffer = inputlabel;
				inputbuffer = Text.inputbuffer;
			}else{
				requestingkeyboardfocus = id;
			}
		}
		
		if (haskeyboardfocus == id){
			if (requestingkeyboardfocus == id){
				requestingkeyboardfocus = "";
			}
			
			inputbuffer = Text.inputbuffer;
			if (Input.justpressed(Key.ENTER) || 
			    Input.justpressed(Key.ESCAPE) || 
					(Mouse.leftclick() && hotitem != id) || requestingkeyboardfocus != ""){
				value = inputbuffer;
				inputbuffer = ""; Text.inputbuffer = "";
				haskeyboardfocus = "";
				_changed = true;
				return value;
			}
		}
		
    return inputlabel;
	}
	
	public static function texteditor(lines:Int = 4, inputlabel:String, ?customwidth:Int, ?pos:haxe.PosInfos):String{
		updateid("texteditor", pos);
		if (customwidth == null) customwidth = Std.int(guisettings.buttonwidth * 1.5);
		checkactive(customwidth, guisettings.inputboxsize * lines);
		
		var labeldisplay:String = inputlabel;
		if (passwordmode){
			labeldisplay = "";
			for (i in 0 ... inputlabel.length) labeldisplay += "*";
		}
		
		if (haskeyboardfocus == id){
			labeldisplay = inputbuffer;
			if (passwordmode){
				labeldisplay = "";
				for (i in 0 ... inputbuffer.length) labeldisplay += "*";
			}
		
			windowlist[currentwindow].fillbox(internalx, internaly, customwidth, guisettings.inputboxsize * lines, style.border);
			windowlist[currentwindow].drawbox(internalx, internaly, customwidth, guisettings.inputboxsize * lines, style.activehighlight);
			if(flash.Lib.getTimer() % 400 > 200){
				windowlist[currentwindow].print(internalx + 3, internaly + guisettings.inboxboxtextyoffset, labeldisplay + "_", style.textcol);
			}else{
				windowlist[currentwindow].print(internalx + 3, internaly + guisettings.inboxboxtextyoffset, labeldisplay, style.textcol);
			}
		}else	if (activeitem == id && hotitem == id){
			windowlist[currentwindow].fillbox(internalx, internaly, customwidth, guisettings.inputboxsize * lines, style.border);
			windowlist[currentwindow].drawbox(internalx, internaly, customwidth, guisettings.inputboxsize * lines, style.activehighlight);
			windowlist[currentwindow].print(internalx + 3, internaly + guisettings.inboxboxtextyoffset, labeldisplay, style.textcol);
		}else	if (hotitem == id){			
			windowlist[currentwindow].fillbox(internalx, internaly, customwidth, guisettings.inputboxsize * lines, style.border);
			windowlist[currentwindow].drawbox(internalx, internaly, customwidth, guisettings.inputboxsize * lines, style.highlight);
			windowlist[currentwindow].print(internalx + 3, internaly + guisettings.inboxboxtextyoffset, labeldisplay, style.textcol);
		}else{
			windowlist[currentwindow].fillbox(internalx, internaly, customwidth, guisettings.inputboxsize * lines, style.border);
			windowlist[currentwindow].drawbox(internalx, internaly, customwidth, guisettings.inputboxsize * lines, style.button);
			windowlist[currentwindow].print(internalx + 3, internaly + guisettings.inboxboxtextyoffset, labeldisplay, style.textcol);
		}
		
		if (Input.justpressed(Key.TAB)){
			//Give keyboard focus to the next keyboard widget
			requestingkeyboardfocus = "-";
			Input.forcerelease(Key.TAB);
		}
		
		if ((requestingkeyboardfocus == id || requestingkeyboardfocus == "-") && haskeyboardfocus == ""){
			requestingkeyboardfocus = "";
			haskeyboardfocus = id;
			Text.inputbuffer = inputlabel;
			inputbuffer = Text.inputbuffer;
		}
		
		if (Mouse.leftclick() && hotitem == id && activeitem == id){
			if(haskeyboardfocus == ""){
				haskeyboardfocus = id;
				Text.inputbuffer = inputlabel;
				inputbuffer = Text.inputbuffer;
			}else{
				requestingkeyboardfocus = id;
			}
		}
		
		if (haskeyboardfocus == id){
			if (requestingkeyboardfocus == id){
				requestingkeyboardfocus = "";
			}
			
			inputbuffer = Text.inputbuffer;
			if (Input.justpressed(Key.ENTER)){
				Text.inputbuffer += "\n";
			}
			if (Input.justpressed(Key.ESCAPE) || 
					(Mouse.leftclick() && hotitem != id) || requestingkeyboardfocus != ""){
				value = inputbuffer;
				inputbuffer = ""; Text.inputbuffer = "";
				haskeyboardfocus = "";
				_changed = true;
				return value;
			}
		}
		
		return inputlabel;
	}
	
	public static function menuitem(label:String, ?minwidth:Float = 0, ?pos:haxe.PosInfos):Bool{
		if (elementtype == "menuitem"){
			windowlist[currentwindow].y -= guisettings.buttonspacing;
		}
		
		updateid("menuitem", pos);
		
		var shadowwidth:Float = -1;
		if (guimenuitemcache.exists(id)){
			var temp:GuiCache = guimenuitemcache.get(id);
			if (label == temp.text){
				shadowwidth = temp.width;
			}else{
				temp.volatile = true;
				shadowwidth = Std.int(Text.width(label) + Std.int(guisettings.scrollbarwidth * 1.5) + 5);
				if (shadowwidth < minwidth) shadowwidth = minwidth;
			}
		}
		
		if(shadowwidth == -1){
			shadowwidth = Std.int(Text.width(label) + Std.int(guisettings.scrollbarwidth * 1.5) + 5);
			if (shadowwidth < minwidth) shadowwidth = minwidth;
			var temp:GuiCache = new GuiCache();
			temp.text = label;
			temp.width = Std.int(shadowwidth);
		  guimenuitemcache.set(id, temp);
		}
		checkactive(shadowwidth, guisettings.checkboxsize);
		
		if (activeitem == id && hotitem == id){
			windowlist[currentwindow].fillbox(internalx, internaly, shadowwidth, guisettings.checkboxsize, style.highlight);
			windowlist[currentwindow].print(internalx + 5, internaly, label, style.textcol);
		}else	if (hotitem == id){
			windowlist[currentwindow].fillbox(internalx, internaly, shadowwidth, guisettings.checkboxsize, style.button);
			windowlist[currentwindow].print(internalx + 5, internaly, label, style.textcol);
		}else{
			windowlist[currentwindow].fillbox(internalx, internaly, shadowwidth, guisettings.checkboxsize, style.border);
			windowlist[currentwindow].print(internalx + 5, internaly, label, style.textcol);
		}
		
		if (debugmode){
			windowlist[currentwindow].skipboundarycheck = true;
			windowlist[currentwindow].fillbox(internalx, internaly, shadowwidth, guisettings.checkboxsize, Col.BLACK, 0.5);
			windowlist[currentwindow].skipboundarycheck = true;
			windowlist[currentwindow].print(internalx, internaly, id, Col.WHITE, 1, guisettings.font, Std.int(guisettings.size / 2));
		}
		
		if (Mouse.leftclick() && hotitem == id && activeitem == id){
			return true;
		}
    return false;
	}
	
	public static function radio(label:String, currentstate:Bool, ?pos:haxe.PosInfos):Bool{
		updateid("radio", pos);
		
		var shadowwidth:Int = -1;
		
		if (guiradiocache.exists(id)){
			var temp:GuiCache = guiradiocache.get(id);
			if (temp.text == label){
				shadowwidth = temp.width;
			}else{
				temp.volatile = true;
				shadowwidth = Std.int(Text.width(label) + Std.int(guisettings.scrollbarwidth * 1.5) + 5);
			}
		}
		
		if(shadowwidth == -1){
		  shadowwidth = Std.int(Text.width(label) + Std.int(guisettings.scrollbarwidth * 1.5) + 5);
			var temp:GuiCache = new GuiCache();
			temp.text = label;
			temp.width = Std.int(shadowwidth);
			guiradiocache.set(id, temp);
		}
		
		checkactive(shadowwidth, guisettings.checkboxsize);
		
		windowlist[currentwindow].fillbox(internalx, internaly, guisettings.scrollbarwidth, guisettings.checkboxsize, style.border);
			
		if (activeitem == id && hotitem == id){
			windowlist[currentwindow].fillbox(internalx, internaly, shadowwidth, guisettings.checkboxsize, style.border, 0.3);
			
			windowlist[currentwindow].drawbox(internalx, internaly, guisettings.scrollbarwidth, guisettings.checkboxsize, style.activehighlight);
			if (currentstate){
				windowlist[currentwindow].fillbox(internalx + 2, internaly + 2, guisettings.scrollbarwidth - 4, guisettings.checkboxsize - 4, style.activehighlight);
			}
			windowlist[currentwindow].print(internalx + guisettings.scrollbarwidth + 5, internaly, label, style.textcol);
		}else	if (hotitem == id){
			windowlist[currentwindow].fillbox(internalx, internaly, shadowwidth, guisettings.checkboxsize, style.border, 0.2);
			
			windowlist[currentwindow].drawbox(internalx, internaly, guisettings.scrollbarwidth, guisettings.checkboxsize, style.activehighlight);
			if (currentstate){
				windowlist[currentwindow].fillbox(internalx + 2, internaly + 2, guisettings.scrollbarwidth - 4, guisettings.checkboxsize - 4, style.activehighlight);
			}
			windowlist[currentwindow].print(internalx + guisettings.scrollbarwidth + 5, internaly, label, style.textcol);
		}else{
			windowlist[currentwindow].drawbox(internalx, internaly, guisettings.scrollbarwidth, guisettings.checkboxsize, style.highlight);
			if (currentstate){
				windowlist[currentwindow].fillbox(internalx + 2, internaly + 2, guisettings.scrollbarwidth - 4, guisettings.checkboxsize - 4, style.highlight);
			}
			windowlist[currentwindow].print(internalx + guisettings.scrollbarwidth + 5, internaly, label, style.textcol);
		}
		
		if (Mouse.leftclick() && hotitem == id && activeitem == id){
			value = !currentstate;
			_changed = true;
			return value;
		}
    return currentstate;
	}
	
	public static function window(?label:String, ?_x:Float = -1, ?_y:Float = -1, ?_spacing:Int = -1, ?pos:haxe.PosInfos){
		updateid("window", pos);
		
		var w:Int = getwindow();
		windowhierarchy.push(w);
		
		windowlist[w].init(((_x == -1)?Text.CENTER:_x), ((_y == -1)?Text.CENTER:_y), posid(pos));
		windowlist[w].type = 1;
		currentwindow = w;
		if (_spacing == -1){
			windowlist[w].boundaryspacing = guisettings.buttonspacing;
		}else{
			windowlist[w].boundaryspacing = _spacing;
		}
		
		if (windowlist[currentwindow].x == Text.RIGHT){
			windowlist[currentwindow].x = Gfx.screenwidth - Std.int(windowlist[currentwindow].windowmemory.boundaryw);
			windowlist[currentwindow].windowmemory.newboundaryx = windowlist[currentwindow].windowmemory.boundaryx = windowlist[currentwindow].x + windowlist[currentwindow].windowmemory.windowxoff;
		}else	if (windowlist[currentwindow].x == Text.CENTER){
			windowlist[currentwindow].x = Gfx.screenwidthmid - Std.int(windowlist[currentwindow].windowmemory.boundaryw / 2);
			windowlist[currentwindow].windowmemory.newboundaryx = windowlist[currentwindow].windowmemory.boundaryx = windowlist[currentwindow].x + windowlist[currentwindow].windowmemory.windowxoff;
		}else{
			internalx = windowlist[currentwindow].x;
			windowlist[currentwindow].windowmemory.newboundaryx = windowlist[currentwindow].windowmemory.boundaryx = windowlist[currentwindow].x + windowlist[currentwindow].windowmemory.windowxoff;
		}
		windowlist[currentwindow].x += guisettings.buttonspacing;
		
		if (windowlist[currentwindow].y == Text.BOTTOM){
			windowlist[currentwindow].y = Gfx.screenheight - Std.int(windowlist[currentwindow].windowmemory.boundaryh);
			windowlist[currentwindow].windowmemory.newboundaryy = windowlist[currentwindow].windowmemory.boundaryy = windowlist[currentwindow].y + windowlist[currentwindow].windowmemory.windowyoff;
		}else if (windowlist[currentwindow].y == Text.CENTER){
			windowlist[currentwindow].y = Gfx.screenheightmid - Std.int(windowlist[currentwindow].windowmemory.boundaryh / 2);
			windowlist[currentwindow].windowmemory.newboundaryy = windowlist[currentwindow].windowmemory.boundaryy = windowlist[currentwindow].y + windowlist[currentwindow].windowmemory.windowyoff;
		}else{
			internaly = windowlist[currentwindow].y;
			windowlist[currentwindow].windowmemory.newboundaryy = windowlist[currentwindow].windowmemory.boundaryy = windowlist[currentwindow].y + windowlist[currentwindow].windowmemory.windowyoff;			
		}
		windowlist[currentwindow].y += guisettings.buttonspacing;
		
		var w:Float = windowlist[currentwindow].windowmemory.boundaryw;
		var h:Float = windowlist[currentwindow].windowmemory.boundaryh;
		
		Text.setfont(guisettings.font, guisettings.size);
		
		windowlist[currentwindow].skipboundarycheck = true;
  	windowlist[currentwindow].fillbox(windowlist[currentwindow].windowmemory.boundaryx, windowlist[currentwindow].windowmemory.boundaryy, w, h, style.border);
		  
		if (windowlist[currentwindow].boundaryspacing == 0){
			windowlist[currentwindow].skipboundarycheck = true;
		  windowlist[currentwindow].drawbox(windowlist[currentwindow].windowmemory.boundaryx - 1, windowlist[currentwindow].windowmemory.boundaryy - 1, w + 2, h + 2, style.button);
		}
		
		adjustposition(windowlist[currentwindow].windowmemory.windowxoff, windowlist[currentwindow].windowmemory.windowyoff);
		
		if (label != null){
			if (label != ""){
				var windowid:String = id;
				windowlist[currentwindow].skipboundarycheck = true;
				windowlist[currentwindow].fillbox(
					windowlist[currentwindow].windowmemory.boundaryx, 
					windowlist[currentwindow].windowmemory.boundaryy, 
					windowlist[currentwindow].windowmemory.boundaryw, 
					guisettings.textheight, 
					style.windowheader);
				adjustposition(0, -guisettings.buttonspacing);
				text(label);
				adjustposition(0, guisettings.buttonspacing);
				id = windowid;
			}
		}
		
		if (debugmode){
			windowlist[currentwindow].skipboundarycheck = true;
			windowlist[currentwindow].fillbox(internalx, internaly, w, h, Col.BLACK, 0.5);
			windowlist[currentwindow].skipboundarycheck = true;
			windowlist[currentwindow].print(internalx, internaly, id, Col.WHITE, 1, guisettings.font, Std.int(guisettings.size / 2));
		}
	}
	
	public static function end(){
		//Go back to the layer below
		if(windowlist[currentwindow].windowmemory.layoutpass){
			windowlist[currentwindow].finishboundary();
		}
		
		if (windowlist[currentwindow].type == 1){ //Movable windows
			if (Geom.inbox(Mouse.x, Mouse.y, 
				windowlist[currentwindow].windowmemory.boundaryx, 
				windowlist[currentwindow].windowmemory.boundaryy,
				windowlist[currentwindow].windowmemory.boundaryw,
				windowlist[currentwindow].windowmemory.boundaryh)){
				hotitem = windowlist[currentwindow].id;
				if (activeitem == "" && Mouse.leftheld()){
					activeitem = windowlist[currentwindow].id;
				}
			}
			
			if (activeitem == windowlist[currentwindow].id){
				windowlist[currentwindow].windowmemory.windowxoff += Mouse.deltax;
				windowlist[currentwindow].windowmemory.windowyoff += Mouse.deltay;
			}
		}
		
		windowhierarchy.pop();
		if (windowhierarchy.length == 0){
			currentwindow = 0;
		}else{
			currentwindow = windowhierarchy[windowhierarchy.length - 1];
		}
	}
	
	public static function shift(){
		windowlist[currentwindow].horizontalmove();
	}
	
	public static function nextrow(){
		windowlist[currentwindow].nextrow();
	}
	
	public static function space(){
		windowlist[currentwindow].y += guisettings.buttonspacing;
	}
	
	public static function adjustposition(_x:Float, _y:Float){
		windowlist[currentwindow].x += _x;
		windowlist[currentwindow].y += _y;
	}
	
	public static function moveto(_x:Float, _y:Float){
		if(windowlist[currentwindow].type == 1){
			windowlist[currentwindow].x = windowlist[currentwindow].windowmemory.boundaryx + _x;
			windowlist[currentwindow].y = windowlist[currentwindow].windowmemory.boundaryy + _y;
		}else{
			windowlist[currentwindow].x = _x;
			windowlist[currentwindow].y = _y;
		}
	}
	
	public static function align(newalignment:Int){
		alignment = newalignment;
	}
	
	public static function setfont(_font:String, ?_size:Float){
		if (!enabled) enable();
		guisettings = new GuiSettings(_font, ((_size==null)?1:_size));
	}
	
	private static function idinuse(id:String):Bool{
		for (i in 0 ... previousid_pos){
			if (previousid[i] == id) return true;
		}
		return false;
	}
	
	private static function posid(pos:haxe.PosInfos):String{		
		newid = pos.fileName + "_" + pos.lineNumber;
		while (idinuse(newid)) newid = newid + "_";
		if (previousid_pos < previousid.length){
			previousid[previousid_pos] = newid;
		}else{
			previousid.push(newid);
		}
		previousid_pos++;
		return newid;
	}
	
	private static function enable(){
		if (!enabled){
      Core.registerplugin("gui", "0.1.0");
      Core.checkrequirement("gui", "haxegon", "0.12.0");
			Core.extend_startframe(prepare);
			Core.extend_endframe(finish);
			
			guisettings = new GuiSettings("default", 1);
			style = new GuiStyle();
			enabled = true;
			
			hotitem = "";
			activeitem = "";
			id = "";
			idcount = 0;
			haskeyboardfocus = "";
			requestingkeyboardfocus = "";
			previoushotitem = "";
			previousid = [];
			previousid_pos = 0;
			
			windowlist = [];
			windowhierarchy = [];
			guiwindowmemory = new Map<String, Dynamic>();
			guimenuitemcache = new Map<String, GuiCache>();
			guimenubarcache = new Map<String, GuiCache>();
			guiradiocache = new Map<String, GuiCache>();
			guitextlabelcache = new Map<String, GuiCache>();
			guiprintcache = new Map<String, GuiPrintCache>();
			prepare();
		}
	}
	private static var enabled:Bool = false;
	
	private static function prepare(){
		id = "";
		previousid_pos = 0;
		idcount = 0;
		hotitem = "";
		
		for (i in 0 ... windowlist.length){
			windowlist[i].active = false;
			for (j in 0 ... windowlist[i].rendercommand.length){
				windowlist[i].rendercommand[j].active = false;
			}
			windowlist[i].lastrendercommand = 0;
		}
		
		var w:Int = getwindow();
		windowlist[w].init(guisettings.buttonspacing, guisettings.buttonspacing, "frame");
		windowlist[w].type = 0;
		currentwindow = w;
		
		windowhierarchy = [w];
		
		alignment = Text.LEFT;
	}
	
	private static function getwindow():Int{
		for (i in 0 ... windowlist.length){
			if (windowlist[i].active == false) return i;
		}
		
		windowlist.push(new GuiWindow());
		return windowlist.length - 1;
	}
	
	private static function finish(){
		textfont = Text.font;
		textalign = Text.align;
		textsize = Text.size;
		
		for (i in 0 ... windowlist.length){
			if (!windowlist[i].windowmemory.layoutpass){
				for (j in 0 ... windowlist[i].rendercommand.length){
					if (!windowlist[i].rendercommand[j].active) break;
					windowlist[i].rendercommand[j].draw();
				}
			}
		}
		
		Text.font = textfont;
		Text.align = textalign;
		Text.size = textsize;
		
		previoushotitem = hotitem;
		
		if (!Mouse.leftheld()){
			activeitem = "";
		}else{
			if (activeitem == ""){
				activeitem = "-";
			}
		}
	}
	
	private static function mouseoverwindow():Bool{
		for (i in 0 ... windowlist.length){
			if(windowlist[i].type != 0){
				if (!windowlist[i].windowmemory.layoutpass){
					if (Geom.inbox(Mouse.x, Mouse.y, 
						windowlist[i].windowmemory.newboundaryx,
						windowlist[i].windowmemory.newboundaryy,
						windowlist[i].windowmemory.newboundaryw,
						windowlist[i].windowmemory.newboundaryh)){
							return true;
					}
				}
			}
		}
		
		return false;
	}
	
	public static var x(get, set):Float;
	public static var y(get, set):Float;
	
	static function get_x():Float {
		return windowlist[currentwindow].x;
	}
	
	static function get_y():Float {
		return windowlist[currentwindow].y;
	}
	
	static function set_x(newx:Float):Float {
		windowlist[currentwindow].x = windowlist[currentwindow].windowmemory.boundaryx + newx;
		return windowlist[currentwindow].x;
	}
	
	static function set_y(newy:Float):Float {
		windowlist[currentwindow].y = windowlist[currentwindow].windowmemory.boundaryy + newy;
		return windowlist[currentwindow].y;
	}
	
	private static var textfont:String;
	private static var textalign:Int;
	private static var textsize:Float;
	
	private static var passwordmode:Bool = false;
	private static var hotitem:String;
	private static var previoushotitem:String;
	private static var activeitem:String;
	private static var haskeyboardfocus:String;
	private static var requestingkeyboardfocus:String;
	private static var inputbuffer:String;
	private static var id:String = "";
	private static var idcount:Int = 0;
	private static var previousid:Array<String>;
	private static var previousid_pos:Int;
	private static var newid:String = "";
	public static var value:Dynamic = null;
	private static var lastmenuxposition:Float;
	private static var lastmenubar:Dynamic;
	
	private static var windowlist:Array<GuiWindow>;
	private static var windowhierarchy:Array<Int>;
	private static var currentwindow:Int;
	private static var internalx:Float;
	private static var internaly:Float;
	private static var elementtype:String;
	private static var alignment:Int;
	private static var guiwindowmemory:Map<String, Dynamic>;
	private static var guimenuitemcache:Map<String, GuiCache>;
	private static var guimenubarcache:Map<String, GuiCache>;
	private static var guiradiocache:Map<String, GuiCache>;
	private static var guitextlabelcache:Map<String, GuiCache>;
	private static var guiprintcache:Map<String, GuiPrintCache>;
	private static var tempprintcache:GuiPrintCache;
	
	private static var guisettings:GuiSettings;
	public static var style:GuiStyle;
	
	//Delete me eventually, then delete everything that refers to me
	private static var debugmode:Bool = false;
}