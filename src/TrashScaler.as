import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;
import com.Utils.LDBFormat;
import com.Utils.Point;
/*
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
*/

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
	public static var btnMinimizeTop: MovieClip;
	public static var textMinimizeTop: TextField;
	public static var tooltip: TextField;
//    public static var m_Tooltip:TooltipInterface;
	
	public static var windows: Array;
	
	public function TrashScaler(swfRoot:MovieClip)
    {
		isDrag = false;
		windows = new Array();

		var windowTemplates = new Array(
			{ id: 'skillhivesimple', name: '[SWL] Abilities', canCenter: false },
			{ id: 'achievement', name: 'Achievements and Lore', canCenter: false },
			{ id: 'groupfinder', name: 'Activity Finder', canCenter: false },
			{ id: 'agentsystem', name: '[SWL] Agent System', canCenter: false },
			{ id: 'tradepost', name: 'Auction House', canCenter: false },
			{ id: 'bank', name: '[SWL] Bank', canCenter: false },
			{ id: 'challengejournal', name: 'Challenge Journal', canCenter: false },
			{ id: 'charactersheet2d', name: '[SWL] Character Sheet', canCenter: false },
			{ id: 'computerpuzzle', name: 'Computer GHOST interface', canCenter: false },
			{ id: 'dressingroom', name: '[SWL] Dressing Room', canCenter: false },
			{ id: 'emotes', name: '[SWL] Emotes', canCenter: false },
			{ id: 'mediaplayer', name: 'Media (readables, etc)', canCenter: true },
			{ id: 'missionjournalwindow', name: 'Mission Journal', canCenter: false },
			{ id: 'missionrewardcontroller', name: 'Mission Rewards', canCenter: true },
			{ id: 'petinventory', name: 'Pets & Sprints', canCenter: false },
			{ id: 'regionteleport', name: '[SWL] Teleport', canCenter: false },
			{ id: 'mainmenuwindow', name: 'Top Bar / Main Menu', canCenter: false },
			{ id: 'trashscaler\\trashscaler', name: 'TrashScaler Window', canCenter: false },
			{ id: 'itemupgrade', name: '[SWL] Upgrade window', canCenter: false },
			{ id: 'shopcontroller', name: 'Vendor', canCenter: false }
		);

		cont = swfRoot.createEmptyMovieClip("trashScalerContainer",
			swfRoot.getNextHighestDepth());
		var tt = cont.createTextField("trashScalerText", 
			cont.getNextHighestDepth(), 0, 0, 330, 200);
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
		var visvalTop:DistributedValue = DistributedValue.Create("TrashScaler.minimizedTop");
		var vis = visval.GetValue();
		var visTop = visvalTop.GetValue();
		textField._visible = vis;
		
		// text format
		var format:TextFormat = new TextFormat(
			"lib.Aller.ttf", 18, 0xCCCCCC, true, false,
			false);
		t.setNewTextFormat(format);

		// hack: make a big enough window
		var s = '';
		for (var i: Number = 0; i <= windowTemplates.length; i++)
		    s += '\n';
		textField.text = s;
		
		// button text format
		textFormatButton = new TextFormat(
			"lib.Aller.ttf", 16, 0xBBFFFF, true, false, false);

		// tooltip text field
		var tooltf = cont.createTextField("TooltipText", 
			cont.getNextHighestDepth(), 0, 0, 80, 20);
		tooltip = tooltf;
		tooltip._alpha = 80;
		tooltip.autoSize = "left";
		tooltip.embedFonts = true;
		tooltip.backgroundColor = 0x000000;
		tooltip.background = true;
		tooltip.setNewTextFormat(format);
		tooltip._width = tooltip.textWidth;
		tooltip._visible = vis;
		tooltip.text = "";
		tooltip._visible = vis;

		// init scaler items
		for (var i: Number = 0; i < windowTemplates.length; i++)
		{
			var tpl = windowTemplates[i];
		
			// item text field
			var ttf = cont.createTextField(tpl.id + "Text", 
				cont.getNextHighestDepth(), 0, 0, 80, 20);
			var tf: TextField = ttf;
			tf._x = 59;
			tf._y = (i + 1) * 21;
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
			var valCenter:DistributedValue = DistributedValue.Create("TrashScaler." + tpl.id + '.center');
			var btnScaleDown = createButton(tpl.id + 'BtnScaleDown', '-',
				5, (i + 1) * 21);
			var btnScaleUp = createButton(tpl.id + 'BtnScaleUp', '+',
				21, (i + 1) * 21);
			var btnCenter = null;
			if (tpl.canCenter)
				btnCenter = createButton(tpl.id + 'BtnCenter', (valCenter.GetValue() ? "C1" : "C0"),
					37, (i + 1) * 21);
			btnScaleDown._visible = vis;
			btnScaleUp._visible = vis;
			if (btnCenter != null)
				btnCenter._visible = vis;

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
				btnCenter: btnCenter,
				scale: scale,
				textField: tf
			};
			tf.text = w.name + ': ' + w.scale;
			windows.push(w);
		}
		
		// minimize button
		btnMinimize = createButton('btnMinimize',
			(vis ? 'MINIMIZE' : 'TRS'), 130, (windows.length + 1) * 21);
		btnMinimizeTop = createButton('btnMinimizeTop',
			(vis ? 'MINIMIZE' : 'TRS'), 130, -20);
		if (visTop && !vis)
			btnMinimize._visible = false;
		else if (!visTop && !vis)
			btnMinimizeTop._visible = false;
		
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
		else if (name == 'btnMinimizeTop')
			textMinimizeTop = t;
		
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
			else if (w.btnCenter != null && w.btnCenter.hitTest(_root._xmouse, _root._ymouse, true))
			{
				var tf = w.btnCenter[w.id + 'BtnCenterText'];
				var val:DistributedValue = DistributedValue.Create("TrashScaler." + w.id + ".center");
				var cur: Boolean = val.GetValue();
				val.SetValue(!cur);
				tf.text = (!cur ? "C1" : "C0");

/*
	            var tooltipData:TooltipData = new TooltipData();
				tooltipData.m_Descriptions.push('tooltip!');
				tooltipData.m_Padding = 4;
				tooltipData.m_MaxWidth = 200;
				m_Tooltip = TooltipManager.GetInstance().ShowTooltip( w.btnCenter, TooltipInterface.e_OrientationVertical, 0, tooltipData );
				if (m_Tooltip != null)
					m_Tooltip.Close();
*/
				return true;
			}
		}

		// minimize button
		var bottomHit = btnMinimize.hitTest(_root._xmouse, _root._ymouse, true);
		var topHit = btnMinimizeTop.hitTest(_root._xmouse, _root._ymouse, true);
		if (bottomHit || topHit)
		{
			var val:DistributedValue = DistributedValue.Create("TrashScaler.minimized");
			val.SetValue(!val.GetValue());
			var vis = val.GetValue();
			var valTop:DistributedValue = DistributedValue.Create("TrashScaler.minimizedTop");
			valTop.SetValue(topHit);

			for (var i: Number = 0; i < windows.length; i++)
			{
				var w = windows[i];
				w.btnUp._visible = vis;
				w.btnDown._visible = vis;
				if (w.btnCenter != null)
					w.btnCenter._visible = vis;
				w.textField._visible = vis;
			}
			textField._visible = vis;
			tooltip._visible = vis;
			textMinimize.text = (vis ? 'MINIMIZE' : 'TRS');
			textMinimizeTop.text = (vis ? 'MINIMIZE' : 'TRS');
			if (topHit)
			  btnMinimize._visible = vis;
			else btnMinimizeTop._visible = vis;

			return true;
		}
		
		return false;
	}
	
	
	// check for button mouseovers
	static function onOverButton()
	{
		tooltip.text = '';

		// check if mouse is over any buttons
		for (var i: Number = 0; i < windows.length; i++)
		{
			var w = windows[i];
			if (w.btnUp.hitTest(_root._xmouse, _root._ymouse, true))
			{
				tooltip.text = "Increase scale";
			}
			else if (w.btnDown.hitTest(_root._xmouse, _root._ymouse, true))
			{
				tooltip.text = "Decrease scale";
			}
			else if (w.btnCenter != null && w.btnCenter.hitTest(_root._xmouse, _root._ymouse, true))
			{
				var tf = w.btnCenter[w.id + 'BtnCenterText'];
				tooltip.text = (tf.text == 'C0' ? "Enable auto-center" : "Disable auto-center");
			}
		}
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
		// check for button mouseovers
		onOverButton();

		if (!isDrag)
			return;

		cont._x += cont._xmouse - xDrag;
		cont._y += cont._ymouse - yDrag;
	}
	
	// stop dragging
	function onRelease()
	{
		// check for button presses and reset tooltip
		if (onPressButton())
			onOverButton();

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

			var win: MovieClip = _root[w.id];

			// do not scale if it's already scaled correctly
			// just in case low-level API does not catch that
			// always resize mission rewards
			if (win._xscale == w.scale &&
				win._yscale == w.scale &&
				w.id != 'missionrewardcontroller' &&
				w.id != 'mediaplayer' &&
				w.id != 'mainmenuwindow')
				continue;

			// basic resize for all (except media player & dressing room)
			if (w.id != 'mediaplayer' && w.id != 'dressingroom')
			{
				win._xscale = w.scale;
				win._yscale = w.scale;
			}
			var mod: Number = w.scale / 100;

			var val:DistributedValue = DistributedValue.Create("TrashScaler." + w.id + ".center");
			var doCenter: Boolean = val.GetValue();

			// top bar-specific tweaks - scaling the window moves stuff out of the visible area
			if (w.id == 'mainmenuwindow')
			{
				var edge: Number = Stage.width / mod;

				// fix minimap edit mask
				var o = _root['mainmenuwindow']['m_MinimapEditModeMask'];
				o._x = edge - o._width;
				o._xscale = 260 / mod;
				o._yscale = 260 / mod;

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

				// meeehrPack compatibility
				if (_root[w.id]['m_FriendsIconContainer'] != null)
				{
					edge = setTopBarPosition('m_FriendsIconContainer', mod, edge);
				}

				// scale compass and reposition it
				_root['compass']._xscale = w.scale;
				_root['compass']._yscale = w.scale;
				_root['compass']._x = Stage.width / 2 - _root['compass']._width / 2;
			}

			// special resize/center for mission reward windows
			else if (w.id == 'missionrewardcontroller' && doCenter)
			{
				var rewardWindows: Array = _root[w.id].m_RewardWindows;
				for (var j: Number = 0; j < rewardWindows.length; j++)
				{
					var ww: MovieClip = rewardWindows[j];
					ww._x = (Stage.width / mod - ww._width) / 2;
					ww._y = (Stage.height / mod - ww._height) / 2;
				}
			}

			// special logic for media player windows
			else if (w.id == 'mediaplayer')
			{
				// always center media player window
				if (doCenter)
				{
					win = _root[w.id]['m_Window'];
					win._x = (Stage.width - win._width) / 2;
					win._y = (Stage.height - win._height) / 2;
					if (win._x < 10)
						win._x = 10;
					if (win._y < 10)
						win._y = 10;
				}

				win = _root[w.id]['m_Window']['m_Content']['m_ImageView'];
				win._xscale = w.scale;
				win._yscale = w.scale;
				var width = win._width;
				var height = win._height;

				win = _root[w.id]['m_Window']['m_Background'];
				win._width = width + 50;
				win._height = height + 50;

				win = _root[w.id]['m_Window']['m_CloseButton'];
				win._x = width;

				win = _root[w.id]['m_Window']['m_DropShadow'];
				win._width = width + 80;
				win._height = height + 80;
			}

			// special logic for dressing room windows
			else if (w.id == 'dressingroom')
			{
				// rescale left panel and center
				win = _root[w.id]['m_LeftPanel'];
				win._xscale = w.scale;
				win._yscale = w.scale;
				win._x = (Stage.width / 2 - win._width) / 2;
				win._y = (Stage.height - win._height) / 2;
				if (win._x < 10)
					win._x = 10;
				if (win._y < 10)
					win._y = 10;

				// rescale right panel and center
				win = _root[w.id]['m_RightPanel'];
				win._xscale = w.scale;
				win._yscale = w.scale;
				win._x = Stage.width / 2 + (Stage.width / 2 - win._width) / 2;
				win._y = (Stage.height - win._height) / 2;
				if (win._x < 10)
					win._x = 10;
				if (win._y < 10)
					win._y = 10;
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
