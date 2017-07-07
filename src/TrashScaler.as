import com.GameInterface.Game.Character;
import com.GameInterface.Quest;
import com.GameInterface.QuestTask;
import com.GameInterface.Quests;
import com.GameInterface.UtilsBase;
import com.Utils.LDBFormat;
import com.Utils.Point;
 

class TrashScaler
{
	// made all fields static because of weird scope bugs
	public static var cont: MovieClip;
	public static var textField: TextField;
	public static var textFormatButton: TextFormat;
	public static var isDrag: Boolean;
	public static var xDrag: Number;
	public static var yDrag: Number;
	
	public static var windows: Array;
	
	public function TrashScaler(swfRoot:MovieClip)
    {
		isDrag = false;
		windows = new Array();
		
		cont = swfRoot.createEmptyMovieClip("trashScalerContainer",
			swfRoot.getNextHighestDepth());
		var tt = cont.createTextField("trashScalerText", 
			cont.getNextHighestDepth(), 0, 0, 300, 200);
		var t: TextField = tt;
		cont._x = (Stage.width - cont._width) / 2;
		cont._y = (Stage.height - cont._height) / 2;
		cont.backgroundColor = 0x000000;
		cont.background = true;
/*
		cont.beginFill(0xFF0000);
		UtilsBase.PrintChatText("" + cont._width);		
		cont.moveTo(10, 0); 
		cont.lineTo(cont._width, 10);
		cont.lineTo(cont._width, cont._height); 
		cont.lineTo(10, cont._height); 
		cont.lineTo(10, 10); 
		cont.endFill();
*/
		
		t._alpha = 80;
		t.autoSize = "left";
		t.html = true;
		t.embedFonts = true;
		t.multiline = true;
		t.wordWrap = true;
		t.backgroundColor = 0x000000;
		t.background = true;
		textField = t;
		
		// text format
		var format:TextFormat = new TextFormat(
			"lib.Aller.ttf", 18, 0xCCCCCC, true, false,
			false);
		t.setNewTextFormat(format);
		textField.text = '\n\n\n\n\n';
		
		// button text format
		textFormatButton = new TextFormat(
			"lib.Aller.ttf", 16, 0xBBFFFF, true, false, false);

		// init scaler items
		var windowTemplates = new Array(
			{ id: 'achievement', name: 'Achievements and Lore' },
			{ id: 'missionjournalwindow', name: 'Mission Journal' }
		);
		for (var i: Number = 0; i < windowTemplates.length; i++)
		{
			var tpl = windowTemplates[i];
		
			// item text field
			var ttf = cont.createTextField(tpl.id + "Text", 
				cont.getNextHighestDepth(), 0, 0, 80, 20);
			var tf: TextField = ttf;
			tf._x = 40;
			tf._y = i * 22;
			tf._alpha = 80;
			tf.autoSize = "left";
			tf.html = true;
			tf.embedFonts = true;
			tf.backgroundColor = 0x000000;
			tf.background = true;
			tf.setNewTextFormat(format);
			tf._width = tf.textWidth;

			// create all buttons
			var btnScaleDown = createButton(tpl.id + 'BtnScaleDown', '-',
				5, i * 22);
			var btnScaleUp = createButton(tpl.id + 'BtnScaleUp', '+',
				21, i * 22);
			var w = {
				id: tpl.id,
				name: tpl.name,
				btnDown: btnScaleDown,
				btnUp: btnScaleUp,
				scale: 100,
				textField: tf
			};
			tf.text = w.name + ': ' + w.scale;
			windows.push(w);
		}
		
		// mouse events
		cont.onRelease = onRelease;
		cont.onPress = onPress;
		var mouseListener = new Object;
		mouseListener.onMouseMove = onMouseMove;
		Mouse.addListener(mouseListener);

		// hax: rescale all windows every 0.5 seconds
		setInterval(rescale, 500);
    }
	
	
	// create simple button with text on it
	function createButton(name: String, s: String, x: Number, y: Number): MovieClip
	{
		var btn = cont.createEmptyMovieClip(name, 
			cont.getNextHighestDepth());
		var tt = btn.createTextField(name + "Text",
			cont.getNextHighestDepth(),
			x, y, 20, 20);
		var t: TextField = tt;
		t.autoSize = "left";
		t.backgroundColor = 0x111111;
		t.background = true;
		t.setNewTextFormat(textFormatButton);
		t.text = s;
		
		return btn;
	}
	
	
	static function onPressButton(): Boolean
	{
		for (var i: Number = 0; i < windows.length; i++)
		{
			var w = windows[i];
			if (w.btnUp.hitTest(_root._xmouse, _root._ymouse, true))
			{
				w.scale += 10;
				w.textField.text = w.name + ': ' + w.scale;
//				UtilsBase.PrintChatText("UP " + w.id);
				return true;
			}
			else if (w.btnDown.hitTest(_root._xmouse, _root._ymouse, true))
			{
				if (w.scale > 10)
					w.scale -= 10;
				w.textField.text = w.name + ': ' + w.scale;
//				UtilsBase.PrintChatText("DOWN " + w.id);
				return true;
			}
		}
		
		return false;
	}
	
	// pressing window and buttons
	function onPress()
	{
		// check for button presses
		if (onPressButton())
			return;
		
		// start dragging
		isDrag = true;
		xDrag = cont._xmouse;
		yDrag = cont._ymouse;
	}
	
	// drag window
	function onMouseMove(id: Number, x: Number, y: Number)
	{
		if (!isDrag)
			return;

		cont._x += cont._xmouse - xDrag;
		cont._y += cont._ymouse - yDrag;
	}
	
	// stop dragging
	function onRelease()
	{
		isDrag = false;
	}
   
	// rescale all windows
	public function rescale()
	{
		for (var i: Number = 0; i < windows.length; i++)
		{
			var w = windows[i];
			_root[w.id]._xscale = w.scale;
			_root[w.id]._yscale = w.scale;
		}
		if (_root.computerpuzzle)
		{
			_root.computerpuzzle._xscale=150;
			_root.computerpuzzle._yscale=150;
		}
		if (_root.missionrewardcontroller)
		{
			_root.missionrewardcontroller._xscale=170;
			_root.missionrewardcontroller._yscale = 170;
			_root.missionrewardcontroller._x = (Stage.width - _root.missionrewardcontroller._width) / 2;
			_root.missionrewardcontroller._y = (Stage.height - _root.missionrewardcontroller._height) / 2;
		}
	}
	

	public static var inst: TrashScaler;
	public static function main(swfRoot:MovieClip):Void
	{
	  inst = new TrashScaler(swfRoot);
	}
}
