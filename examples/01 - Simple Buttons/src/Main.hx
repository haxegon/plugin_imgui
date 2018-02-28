import haxegon.*;

class Main {
	function init(){
		//Use the entire screen
		Gfx.resizescreen(0, 0);
		
		//Use a bigger font so that it looks a bit nicer
		//Tell imGui to use the default font, size 5
		Gui.setfont("default", 5);
	}
	
  function update() {
	  if (Gui.button("quack")){
			Sound.play("quack");
		}
		
		if (Gui.button("meow")){
			Sound.play("meow");
		}
		
		if (Gui.button("woof")){
			Sound.play("woof");
		}
	}
}