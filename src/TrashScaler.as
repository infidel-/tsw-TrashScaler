import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;
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
	public static var btnMinimize: MovieClip;
	public static var textMinimize: TextField;
	
	public static var windows: Array;
	
	public function TrashScaler(swfRoot:MovieClip)
    {
		isDrag = false;
		windows = new Array();

		cont = swfRoot.createEmptyMovieClip("trashScalerContainer",
			swfRoot.getNextHighestDepth());
		var tt = cont.createTextField("trashScalerText", 
			cont.getNextHighestDepth(), 0, 0, 310, 200);
		var t: TextField = tt;
		cont.backgroundColor = 0x000000;
		cont.background = true;

		// set stored window x,y
		var xval:DistributedValue = DistributedValue.Create("TrashScaler.x");
		var x = 0;
		if (xval.GetValue() == -1)
			x = (Stage.width - cont._width) / 2;
		else x = xval.GetValue();
		var yval:DistributedValue = DistributedValue.Create("TrashScaler.y");
		var y = 0;
		if (yval.GetValue() == -1)
			y = (Stage.height - cont._height) / 2;
		else y = yval.GetValue();
		cont._x = x;
		cont._y = y;
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
		
		// set visibility
		var visval:DistributedValue = DistributedValue.Create("TrashScaler.minimized");
		var vis = visval.GetValue();
		textField._visible = vis;
		
		// text format
		var format:TextFormat = new TextFormat(
			"lib.Aller.ttf", 18, 0xCCCCCC, true, false,
			false);
		t.setNewTextFormat(format);
		textField.text = '\n\n\n\n\n\n\n\n\n';
		
		// button text format
		textFormatButton = new TextFormat(
			"lib.Aller.ttf", 16, 0xBBFFFF, true, false, false);

		// init scaler items
		var windowTemplates = new Array(
			{ id: 'achievement', name: 'Achievements and Lore' },
			{ id: 'tradepost', name: 'Auction House' },
			{ id: 'bank', name: 'Bank [SWL]' },
			{ id: 'charactersheet2d', name: 'Character sheet [SWL]' },
			{ id: 'computerpuzzle', name: 'Computer GHOST interface' },
			{ id: 'missionjournalwindow', name: 'Mission Journal' },
			{ id: 'missionrewardcontroller', name: 'Mission Rewards' },
			{ id: 'mainmenuwindow', name: 'Top Bar / Main Menu' },
			{ id: 'itemupgrade', name: 'Upgrade window [SWL]' }
		);
		for (var i: Number = 0; i < windowTemplates.length; i++)
		{
			var tpl = windowTemplates[i];
		
			// item text field
			var ttf = cont.createTextField(tpl.id + "Text", 
				cont.getNextHighestDepth(), 0, 0, 80, 20);
			var tf: TextField = ttf;
			tf._x = 40;
			tf._y = i * 21;
			tf._alpha = 80;
			tf.autoSize = "left";
			tf.html = true;
			tf.embedFonts = true;
			tf.backgroundColor = 0x000000;
			tf.background = true;
			tf.setNewTextFormat(format);
			tf._width = tf.textWidth;
			tf._visible = vis;

			// create all buttons
			var btnScaleDown = createButton(tpl.id + 'BtnScaleDown', '-',
				5, i * 21);
			var btnScaleUp = createButton(tpl.id + 'BtnScaleUp', '+',
				21, i * 21);
			btnScaleDown._visible = vis;
			btnScaleUp._visible = vis;

			// init object
			var val:DistributedValue = DistributedValue.Create("TrashScaler." + tpl.id);
			var scale: Number = val.GetValue();
			if (scale == null)
				scale = 100;
			var w = {
				id: tpl.id,
				name: tpl.name,
				btnDown: btnScaleDown,
				btnUp: btnScaleUp,
				scale: scale,
				textField: tf
			};
			tf.text = w.name + ': ' + w.scale;
			windows.push(w);
		}
		
		// minimize button
		btnMinimize = createButton('btnMinimize',
			(vis ? 'MINIMIZE' : 'TRS'), 100, windows.length * 21);
		
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
		
		if (name == 'btnMinimize')
			textMinimize = t;
		
		return btn;
	}
	
	
	// check for button presses
	static function onPressButton(): Boolean
	{
		// check if any buttons are pressed
		for (var i: Number = 0; i < windows.length; i++)
		{
			var w = windows[i];
			if (w.btnUp.hitTest(_root._xmouse, _root._ymouse, true))
			{
				w.scale += 10;
				w.textField.text = w.name + ': ' + w.scale;
				var val:DistributedValue = DistributedValue.Create("TrashScaler." + w.id);
				val.SetValue(w.scale);
//				UtilsBase.PrintChatText("UP " + w.id);
				return true;
			}
			else if (w.btnDown.hitTest(_root._xmouse, _root._ymouse, true))
			{
				if (w.scale > 10)
					w.scale -= 10;
				w.textField.text = w.name + ': ' + w.scale;
				var val:DistributedValue = DistributedValue.Create("TrashScaler." + w.id);
				val.SetValue(w.scale);
//				UtilsBase.PrintChatText("DOWN " + w.id);
				return true;
			}
		}

		// minimize button
		if (btnMinimize.hitTest(_root._xmouse, _root._ymouse, true))
		{
			var val:DistributedValue = DistributedValue.Create("TrashScaler.minimized");
			val.SetValue(!val.GetValue());
			var vis = val.GetValue();
			
			for (var i: Number = 0; i < windows.length; i++)
			{
				var w = windows[i];
				w.btnUp._visible = vis;
				w.btnDown._visible = vis;
				w.textField._visible = vis;
			}
			textField._visible = vis;
			textMinimize.text = (vis ? 'MINIMIZE' : 'TRS');

			return true;
		}
		
		return false;
	}
	
	// pressing window and buttons
	function onPress()
	{
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
		// check for button presses
		onPressButton();

		isDrag = false;

		// save window x,y
		var xval:DistributedValue = DistributedValue.Create("TrashScaler.x");
		var yval:DistributedValue = DistributedValue.Create("TrashScaler.y");
		xval.SetValue(cont._x);
		yval.SetValue(cont._y);
	}
   
	// rescale all windows
	public function rescale()
	{
		// tweak debug window for better visibility
		if (_root['debugwindow'] != null)
		{
			_root['debugwindow']._xscale = 150;
			_root['debugwindow']._yscale = 150;
			_root['debugwindow']._alpha = 200;
		}
		
		for (var i: Number = 0; i < windows.length; i++)
		{
			var w = windows[i];

			// skip unopened windows
			if (_root[w.id] == null || _root[w.id]._xscale == null)
				continue;

			// do not scale if it's already scaled correctly
			// just in case low-level API does not catch that
			// always resize mission rewards
			if (_root[w.id]._xscale == w.scale &&
				_root[w.id]._yscale == w.scale &&
				w.id != 'missionrewardcontroller')
				continue;

			// basic resize for all
			_root[w.id]._xscale = w.scale;
			_root[w.id]._yscale = w.scale;
			var mod: Number = w.scale / 100;

			// top bar-specific tweaks - scaling the window moves stuff out of the visible area
			if (w.id == 'mainmenuwindow')
			{
				var edge: Number = Stage.width / mod;

				// go right to left, setting positions
				edge = setTopBarPosition('m_LockIconContainer', mod, edge);
				edge = setTopBarPosition('m_FPSIconContainer', mod, edge);
				edge = setTopBarPosition('m_MailIconContainer', mod, edge);
				edge = setTopBarPosition('m_ClockIconContainer', mod, edge);
				edge = setTopBarPosition('m_DownloadingIconContainer', mod, edge);

				// SWL-specific
				if (_root[w.id]['m_TokenIconContainer_1'] != null)
				{
					edge = setTopBarPosition('m_TokenIconContainer_1', mod, edge);
					edge = setTopBarPosition('m_TokenIconContainer_2', mod, edge);
				}

				// scale compass and reposition it
				_root['compass']._xscale = w.scale;
				_root['compass']._yscale = w.scale;
				_root['compass']._x = Stage.width / 2 - _root['compass']._width / 2;
			}

			// special resize/center for mission reward windows
			else if (w.id == 'missionrewardcontroller')
			{
				var rewardWindows: Array = _root[w.id].m_RewardWindows;
				for (var j: Number = 0; j < rewardWindows.length; j++)
				{
					var ww: MovieClip = rewardWindows[j];
					ww._x = (Stage.width / mod - ww._width) / 2;
					ww._y = (Stage.height / mod - ww._height) / 2;
				}
			}
		}
	}


	// center given window
	static function centerWindow(w: MovieClip)
	{
		w._x = Stage.width / 2 - w._width / 2;
		w._y = Stage.height / 2 - w._height / 2;
		UtilsBase.PrintChatText('pos:' + w._x + ',' + w._y +
			' sz:' + w._width + ',' + w._height);
	}


	// helper for laying out top bar right icons
	static function setTopBarPosition(id: String, mod: Number, edge: Number): Number
	{
		var o = _root['mainmenuwindow'][id];
		o._x = edge - o._width - 10;
		return o._x;
	}
	

	public static var inst: TrashScaler;
	public static function main(swfRoot:MovieClip):Void
	{
	  inst = new TrashScaler(swfRoot);
	}
}
