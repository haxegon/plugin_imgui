import haxegon.*;

class Main {
	function init(){
		//Use the entire screen
		Gfx.resizescreen(0, 0);
		
		//Use a bigger font so that it looks a bit nicer
		//Tell imGui to use the ttf font "opensans", size 20
		Gui.setfont("opensans", 20);
	}
	
  function update() {
		Gui.window("Soundboard", 0);
		
	  if (Gui.button("quack")){
			Sound.play("quack", 0, loopsounds);
		}
		
		Gui.shift();
		
		if (Gui.button("meow")){
			Sound.play("meow", 0, loopsounds);
		}
		
		Gui.nextrow();
		
		if (Gui.button("woof")){
			Sound.play("woof", 0, loopsounds);
		}
		
		Gui.shift();
		
		if (Gui.button("stop all sounds")){
			Sound.stop();
		}
		
		Gui.nextrow();
		
		Gui.text("Volume: " + Sound.mastervolume);
		Sound.mastervolume = Gui.slider(400, 0, 1, Sound.mastervolume);
		
		loopsounds = Gui.radio("loop sounds?", loopsounds);
		
		Gui.end();
		
		Gui.window("Different window", Gfx.screenwidthmid);
		
		Gui.text("This is a different window.");
		Gui.text("This button does nothing!");
		
		Gui.button("Ok then");
		
		Gui.end();
	}
	
	var loopsounds:Bool = false;
}