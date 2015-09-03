package nl.bs10.bright.model.vo {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.objects.Administrator;
	
	[Event(name="editAdministratorChanged", type="flash.events.Event")]
	[Event(name="settingsChanged", type="nl.bs10.brightlib.events.BrightEvent")]
	[Bindable]
	public class AdministratorVO extends EventDispatcher {
	
		private var _editAdministrator:Administrator;
		
		private var _administrator:Administrator;
		
		public var administrators:Array = new Array();
		
		public var administratorActions:Array = [];
		
		
		public var lastLoginAttempt:Date;
		public var lastLoginEmail:String;
		public var lastLoginPassword:String;
		
		public var callbacks:Array = [];
		
		/**
		 * Sets a setting for the administrator 
		 * @param setting The (path to) the setting (e.g. maps.displayMode)
		 * @param value The value of the setting
		 */		
		public function setSetting(setting:String, value:*, callback:Function = null):void {
			var path:Array = setting.split('.');
			if(!administrator.settings) {
				administrator.settings = {};
			}
			var current:Object = administrator.settings;
			for(var i:int = 0; i < path.length; i++) {
				
				if(!current.hasOwnProperty(path[i])) {
					
					current[path[i]] = {};
					
				} 
				if(i == path.length -1) {
					if(!value) {
						delete current[path[i]]
					} else {
						current[path[i]] = value;
					}
				}
				current = current[path[i]];
			}
			dispatchEvent(new BrightEvent('settingsChanged', setting));
			if(callback != null)
				callbacks.push(callback);
		}
		
		public function getSetting(setting:String):* {
			if(!setting)
				return null;
			
			var path:Array = setting.split('.');
			if(!administrator.settings) {
				administrator.settings = {};
			}
			var current:Object = administrator.settings;
			for(var i:int = 0; i < path.length; i++) {
				
				if(!current.hasOwnProperty(path[i]) && i != path.length -1) {
					current[path[i]] = {};
				} 
				if(i == path.length -1){
					return current[path[i]];
				}
				current = current[path[i]];
			}
			return null;
		}
		
		public function set editAdministrator(value:Administrator):void {
			_editAdministrator = value;
			dispatchEvent(new Event("editAdministratorChanged"));
		}	
		
		public function get editAdministrator():Administrator {
			return _editAdministrator;
		}

		public function get administrator():Administrator
		{
			return _administrator;
		}

		public function set administrator(value:Administrator):void
		{
			if(value != _administrator) {
				if(_administrator) {
					_administrator.removeEventListener('labelsChanged', _updateLabels);
				}
				_administrator = value;
				_administrator.addEventListener('labelsChanged', _updateLabels);
			}
		}
		
		private function _updateLabels(event:Event = null):void {
			var arr:Array = [Model.instance.pageVO.pages,Model.instance.mailingVO.mailings,Model.instance.calendarVO.events];
			var sarr:Array = ['page','mailing','calendar'];
			for(var i:int = 0; i < 3; i ++) {
				var labels:Object = Model.instance.administratorVO.getSetting(sarr[i] +'.labels');
				if(labels) {
					for(var label:String in labels) {
						if(arr[i][label]){
							arr[i][label].coloredlabel = "bullet_" + labels[label];
						}
					}
				}
				
			}
			/*for each(var parr:Array in arr) {
				
			}*/
			Model.instance.pageVO.apages.refresh();
			Model.instance.mailingVO.amailings.refresh();
			Model.instance.calendarVO.aevents.refresh();
		}

	}
}