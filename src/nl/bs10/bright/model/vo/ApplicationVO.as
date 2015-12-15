package nl.bs10.bright.model.vo {
	import com.adobe.utils.ArrayUtil;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.IFlexDisplayObject;
	
	import nl.bs10.bright.controllers.PermissionController;
	import nl.bs10.brightlib.controllers.IconController;
	
	
	public class ApplicationVO extends EventDispatcher {

		public static const COPYRIGHT:String = "© 2009 - " + (new Date()).getFullYear() + " Fur, All rights reserved";
		public static const STRUCTUREVIEW:int = 0;
		public static const CONTENTVIEW:int = 1;
		
		public var loginView:IFlexDisplayObject;
		
		/*
		I need to find a decent solution for this....
		*/
		
		/*************************\
		 *     LANGUAGE ICONS    *
		\*************************/
		
 		[Embed (source='/assets/languages/nl.png')]
		private var _nlimg:Class;
		[Embed (source='/assets/languages/de.png')]
		private var _deimg:Class;
		[Embed (source='/assets/languages/en.png')]
		private var _enimg:Class;
		[Embed (source='/assets/languages/fr.png')]
		private var _frimg:Class;
		[Embed (source='/assets/languages/pl.png')]
		private var _plimg:Class; 
		[Embed (source='/assets/languages/es.png')]
		private var _esimg:Class; 
		[Embed (source='/assets/languages/be.png')]
		private var _beimg:Class; 
		
		
		// 0 = login
		// 1 = application
		private var _applicationState:uint;
		
		private var _commandExecuting:Boolean;
		private var _config:Object;
		
		private var _langs:Array;
		private var _localizablefields:Object;
		
		private var _log:String = "";
		
		[Bindable]
		public var navitems:ArrayCollection = new ArrayCollection();
		
		[Bindable]
		public var langimages:Object;
		
		[Bindable]
		public var langlabels:Object;
		
		
		// The view to change to (while pending)
		private var _targetView:int = 0;
		//Number of views who have responded to the event
		private var _responses:int = 0;
		
		public var numListeners:int = 0;
		
		[Bindable]
		public var currentView:int = 0;
		
		[Bindable]
		public var isLoading:Boolean = false;
		
		[Bindable]
		public var loadingInfo:String = "";
		
		[Bindable]
		public var logo:Bitmap = new Bitmap();

		[Bindable]
		public var logo_bw:Bitmap = new Bitmap();
		
		[Bindable]
		public var actioncolor:String = 'green';
		
		[Bindable]
		public var isOnTestServer:Boolean = false;
		
		public var headerItems:ArrayCollection;
		
		public var mapsAvailable:Boolean = true;
		
		public var gateway:String;
		
		
		function ApplicationVO() {
			langimages = {nl:_nlimg,be:_beimg, en: _enimg, de: _deimg, fr:_frimg, pl:_plimg, es:_esimg, settings:IconController.SETTINGS};	
			langlabels = {	nl: "Nederlands", 
							en: "English", 
							de: "Deutsch", 
							fr: "Français", 
							pl:"Polski", 
							es: "Español", 
							be: "Belgisch", 
							settings:"Settings"};
							
			headerItems = new ArrayCollection([	{name: 'structure', label: 'Structure', index: 0},
												{name: 'files', label: 'File', index: 1},
												{name: 'mailing', label: 'Mailing', index: 2},
												{name: 'calendars', label: 'Calendars', index: 3},
												{name: 'elements', label: 'Elements', index: 4},
												{name: 'gmaps', label: 'Maps', index: 5},	
												{name: 'administrators', label: 'Administrators', index: 6},
												{name: 'users', label: 'Users', index: 7},
												{name: 'templates', label: 'Templates', index: 8},
												{name: 'settings', label: 'Settings', index: 9}]);
		}
		
		[Bindable(event="commandExecutingChanged")] 
		public function set commandExecuting(value:Boolean):void {
			if(value !== _commandExecuting) {
				_commandExecuting = value;
				dispatchEvent(new Event("commandExecutingChanged"));
			}	
		}
		
		/**
		 * @var commandExecuting indicates whether a server action is in progress, bind to this var to enable / disable ui elements
		 */
		public function get commandExecuting():Boolean {
			return _commandExecuting;
		}
		
		/**
		 * Dispatches an event that the window is about to change,
		 * all views are notified and can take action to prevent the change.
		 * When all views have responded positivily, the actual change is performed 
		 * @param target The view to switch to
		 */		
		public function dispatchWindowChangeEvent(target:int):void {
			_responses = 0;
			_targetView = target;
			dispatchEvent(new Event("windowChange"));
			if(numListeners == 0) 
				changeWindow();
		}
		
		/**
		 * Changes the window when all views have responded
		 */		
		public function changeWindow():void {
			_responses++;
			
			if(_responses < numListeners) 
				return;
			
			currentView = _targetView;
		}
		
		public function setNavitems():void {
			var permarr:Array = PermissionController.instance.getPermissions();
			var addstruct:Boolean = false;
			var addtemplate:Boolean = false;
			var addfiles:Boolean = false;
			var adduser:Boolean = false;
			var addsettings:Boolean = false;
			var addadministrators:Boolean = false;
			var addmailing:Boolean = false;
			var addcalendar:Boolean = false;
			var addelements:Boolean = false;
			var addgmaps:Boolean = false;
			for each(var permission:String in permarr) {
				switch(permission) {
					case 'CREATE_PAGE':
					case 'DELETE_PAGE': 
					case 'EDIT_PAGE': 
					case 'MOVE_PAGE':			addstruct = true;			break;
					
					case 'UPLOAD_FILE':
					case 'DELETE_FILE':			addfiles = true;			break;
					
					case 'MANAGE_TEMPLATE':		addtemplate = true;			break;
					case 'MANAGE_USER':			adduser = true;				break;
					case 'MANAGE_SETTINGS':		addsettings = true;			break;
					case 'MANAGE_ADMIN':		addadministrators = true;	break;
					case 'MANAGE_MAILINGS':		addmailing = true;			break;
					case 'MANAGE_CALENDARS':	addcalendar = true;			break;
					case 'MANAGE_ELEMENTS':		addelements = true;			break;
					case 'MANAGE_MAPS':			addgmaps = true;			break;
				}
			}
			
			navitems.removeAll();
			var obj:Object = {};
			obj['administrators'] = true;
			if(addstruct) 					obj['structure'] = true;
			if(addfiles) 					obj['files'] = true;
			//if(addadministrators) 			
			if(adduser) 					obj['users'] = true;
			if(addtemplate) 				obj['templates'] = true;
			if(addsettings) 				obj['settings'] = true;
			if(addmailing) 					obj['mailing'] = true;
			if(addcalendar) 				obj['calendars'] = true;
			if(addelements) 				obj['elements'] = true;
			if(addgmaps && mapsAvailable)	obj['gmaps'] = true;
			var s:Sort = new Sort();
			s.fields = [new SortField('index', false, false, true)];
			headerItems.sort = s;
			headerItems.refresh();
			for each(var headerItem:Object in headerItems) {
				if(obj.hasOwnProperty(headerItem.name) || (config.general.hasOwnProperty("additionalmodules") && ArrayUtil.arrayContainsValue(config.general.additionalmodules, headerItem.name))) {
					navitems.addItem(headerItem);
				}	
			}
		}
		
		
		[Bindable(event="applicationStateChanged")]
		public function set applicationState(value:uint):void {
			if(value !== _applicationState) {
				_applicationState = value;
				dispatchEvent(new Event("applicationStateChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the applicationState property
		 **/
		public function get applicationState():uint {
			return _applicationState;
		}

		public function get config():Object
		{
			return _config;
		}

		[Bindable(event="configChanged")]
		public function set config(value:Object):void
		{
			if(value !== _config) {
				_config = value;
				langs = _config.general.languages;
				dispatchEvent(new Event("configChanged"));
			}
		}

		public function get langs():Array
		{
			return _langs;
		}
		
		[Bindable(event="langsChanged")]
		public function set langs(value:Array):void
		{
			if(value !== _langs) {
				_langs = value;
				dispatchEvent(new Event("langsChanged"));
			}
		}

		public function get localizablefields():Object
		{
			return _localizablefields;
		}
		
		[Bindable(event="localizablefieldsChanged")]
		public function set localizablefields(value:Object):void
		{
			if(value !== _localizablefields) {
				_localizablefields = value;
				localizablefieldsChanged();		
			}
		}
		
		public function localizablefieldsChanged():void {
			dispatchEvent(new Event("localizablefieldsChanged"));
		}
		
		public function get log():String
		{
			return _log;
		}
		
		[Bindable(event="logChanged")]
		public function set log(value:String):void
		{
			if(value !== _log) {
				_log = value;
				dispatchEvent(new Event("logChanged"));	
			}
		}

		
	}
}