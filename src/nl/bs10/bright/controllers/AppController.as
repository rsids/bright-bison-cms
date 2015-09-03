package nl.bs10.bright.controllers {
	
	import com.adobe.utils.ArrayUtil;
	import com.adobe.utils.mousewheel.MouseWheelEnabler;
	
	import flash.debugger.enterDebugger;
	import flash.display.DisplayObject;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import gs.TweenLite;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.managers.ToolTipManager;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	import nl.bs10.bright.Version;
	import nl.bs10.bright.commands.administrators.IsAuthCommand;
	import nl.bs10.bright.commands.administrators.SetSettingsCommand;
	import nl.bs10.bright.commands.config.GetLogoCommand;
	import nl.bs10.bright.commands.config.LogErrorCommand;
	import nl.bs10.bright.commands.custom.AddCustomTableValueCommand;
	import nl.bs10.bright.commands.custom.DeleteCustomTableValueCommand;
	import nl.bs10.bright.commands.custom.GetCustomTableValueCommand;
	import nl.bs10.bright.commands.maps.GetMarkerLabelCommand;
	import nl.bs10.bright.commands.maps.GetMarkersAndPolysCommand;
	import nl.bs10.bright.commands.users.GetUserGroupsCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.skins.palettes.Palette;
	import nl.bs10.bright.views.MainViewLayout;
	import nl.bs10.bright.views.files.FilePopupView;
	import nl.bs10.bright.views.popups.MarkerListPopup;
	import nl.bs10.brightlib.components.ToolTip;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.bs10.brightlib.events.FileExplorerEvent;
	import nl.bs10.brightlib.objects.Administrator;
	import nl.bs10.brightlib.objects.Template;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.events.VeinDispatcher;
	import nl.fur.vein.events.VeinEvent;

	public class AppController extends Application {
		
		private var _appcomplete:Boolean = false;
		private var _iconscomplete:Boolean = false;
		private var _applicationStateChanged:Boolean = false;
		private var _settingsChanged:Boolean = false;
		
		private var _modelRequests:Array = [];
		private var _modelRequested:Boolean = false;
		
		private var _customTableValueRequests:Array = [];
		private var _customTableValueRequested:Boolean = false;
		
		
		[Bindable] public var mainView:MainViewLayout;
		[Bindable] public var actionbar_cvs:Canvas;
		[Bindable] public var action_icon:Image;
		[Bindable] public var action_lbl:Label;
		
		public function AppController():void {
			IconController.init(_loaded);
			addEventListener(FlexEvent.APPLICATION_COMPLETE, _completeHandler, false, 0, true);
			addEventListener(Event.ADDED_TO_STAGE, _enableMouseWheel, false, 0, true);
			Model.instance.applicationVO.addEventListener('applicationStateChanged', _onApplicationStateChanged);
			Model.instance.administratorVO.addEventListener('settingsChanged', _onSettingsChanged, false,0, true);
			ToolTipManager.toolTipClass = ToolTip;
		}
		
		/**
		 * Called from the library. This is the only way to get a model value from the library... 
		 * @param data
		 * @return 
		 * 
		 */		
		public function getAdministrator(data:Object, column:Object):String {
			var id:int = data[column.dataField];
			for each(var admin:Administrator in Model.instance.administratorVO.administrators) {
				if(admin.id == id) {
					return admin.name;
				}
			}
			return '';
		}
		
		/**
		 * Called from plugin
		 */
		public function getDefinitionsById(ids:Array):Array {
			//parentApplication
			var retarr:Array = new Array();
			for each(var definition:Template in Model.instance.templateVO.rawTemplateDefinitions) {
				if(ArrayUtil.arrayContainsValue(ids, definition.id.toString())) {
					retarr.push(definition.fields[0]);
				}
			}
			return retarr;
		}
		
		/**
		 * Gets one or more elements, first, it tries to get them from the model,
		 * if that doesn't work, it'l try to get them from the server
		 * @todo implement in an elegant way :)
		 * @param array	ids An array of pageIds.
		 */ 
		public function getElements(ids:Array):Array{
			return [];
		}
		
		/**
		 * Called from plugin
		 * Gets a value from the model;
		 */
		public function getModelValue(property:String):* {
			var props:Array = property.split('.');
			var m:* = Model.instance;
			for each(var prop:String in props) {
				if(!m.hasOwnProperty(prop))
					return null
				m = m[prop];
			}
			return m;
		}
		
		/**
		 * Called from plugin
		 */
		public function getTemplatesById(ids:Array):Array {
			//parentApplication
			var retarr:Array = new Array();
			for each(var definition:Template in Model.instance.templateVO.rawTemplateDefinitions) {
				if(ArrayUtil.arrayContainsValue(ids, definition.id.toString())) {
					retarr.push(definition);
				}
			}
			return retarr;
		}
		
		/**
		 * Called from plugin
		 * Opens the file explorer;
		 */
		public function openFileExplorer(event:FileExplorerEvent):void {
			var p:IFlexDisplayObject = PopUpManager.createPopUp(this,
				FilePopupView,
				true);
			FilePopupView(p).setProperties(event);
			PopUpManager.centerPopUp(p);
			
		}
		
		/**
		 * Shows the top actionbar 
		 * @param action String containing the type of action, valid values are: delete, info, lock, lock_open, error and success
		 * @param actionlabel An informational string shown in the bar
		 */
		public function showActionBar(action:String, actionlabel:String):void {
			switch(action) {
				case 'delete':
					action_icon.source = IconController.getIcon("delete");
					Model.instance.applicationVO.actioncolor = 'red';
					break;
				
				case 'info':
					action_icon.source = IconController.getIcon("information");
					Model.instance.applicationVO.actioncolor = 'blue';
					break;
					
				case 'lock':
				case 'lock_open':
				case 'error':
					action_icon.source = IconController.getIcon(action);
					Model.instance.applicationVO.actioncolor = 'yellow';
					break;
					
				default:
					action_icon.source = IconController.getIcon("accept");
					Model.instance.applicationVO.actioncolor = 'green';
			}
			action_lbl.text = actionlabel;
			action_lbl.setStyle('color', Palette.instance.strokes[Model.instance.applicationVO.actioncolor + '_stroke'].color);
			TweenLite.to(actionbar_cvs, .5, {alpha:1, onComplete: _hideActionBar});
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_appcomplete && _iconscomplete && _applicationStateChanged) {
				_applicationStateChanged = false;
				Model.instance.applicationVO.removeEventListener('applicationStateChanged', _onApplicationStateChanged);
				mainView.createComponentsFromDescriptors();
			}
			var varname:String;
			if(_modelRequested) {
				_modelRequested = false;
				for(varname in _modelRequests) {
					var props:Array = varname.split('.');
					var m:* = Model.instance;
					var valid:Boolean = true;
					for each(var prop:String in props) {
						if(valid) {
							if(!m.hasOwnProperty(prop)) {
								m = null;
								valid = false;
							} else {
								m = m[prop];
							}
						}
					}
					var dispatch:Boolean = true;
					if(!m) {
						switch(varname) {
							case 'userVO.usergroups':
								
								CommandController.addToQueue(new GetUserGroupsCommand(), true);
								dispatch = false;
								break;
						}
					}
					if(dispatch)
						VeinDispatcher.instance.dispatch('modelRequestResult', {modelname: varname, modelvalue: m});
				}
				
				_modelRequests = [];
			}
			
			if(_customTableValueRequested) {
				_customTableValueRequested = false;
				for(varname in _customTableValueRequests) {
					
					if(Model.instance.settingsVO.customTables.hasOwnProperty(varname)) {
						VeinDispatcher.instance.dispatch('customTableValueRequestResult', {tablename: varname, value: Model.instance.settingsVO.customTables[varname] });
					} else {
						CommandController.addToQueue(new GetCustomTableValueCommand(), varname);
					}

				}
				
				_customTableValueRequests = [];
			}
			
			if(_settingsChanged) {
				_settingsChanged = false;
				CommandController.addToQueue(new SetSettingsCommand(), Model.instance.administratorVO.administrator.settings);
			}
		}
		
		private function _authHandler(event:ContextMenuEvent):void {
			navigateToURL(new URLRequest("http://www.wewantfur.com"), "_blank");
		}
		
		private function _completeHandler(event:FlexEvent):void {
			_appcomplete = true;
			
			Model.instance.applicationVO.isOnTestServer = (loaderInfo.loaderURL.indexOf('localhost') != -1 || loaderInfo.loaderURL.indexOf('wantsfur') != -1);
			
			invalidateProperties();
			
			Alert.buttonWidth = 100;
			var gateway:String = Model.instance.applicationVO.gateway = Application.application.parameters.gateway;
			var services:Array = [{name:"treeService", source:"tree.Tree"},
									{name:"templateService", source:"template.Template"},
									{name:"pageService", source:"page.Page"},
									{name:"mailingService", source:"mailing.Mailing"},
									{name:"calendarService", source:"calendar.Calendar"},
									{name:"cacheService", source:"cache.Cache"},
									{name:"adminService", source:"administrator.Administrator"},
									{name:"configService", source:"config.Config"},
									{name:"settingsService", source:"config.Settings"},
									{name:"userService", source:"user.User"},
									{name:"elementService", source:"element.Element"},
									{name:"mapsService", source:"maps.Maps"},
									{name:"layerService", source:"maps.Layers"},
									{name:"customService", source:"custom.CustomActions"},
									{name:"listService", source:"custom.Lists"},
									{name:"usergroupService", source:"user.UserGroup"}];
			
			for each(var service:Object in services) {
				var ro:RemoteObject = new RemoteObject("gateway");
				ro.endpoint = gateway;
				ro.source = service.source;
				ServiceController.addRemotingService(ro, service.name);
			}
			CommandController.addToQueue(new GetLogoCommand());
			CommandController.addToQueue(new IsAuthCommand());
			
			// Setup listeners
			VeinDispatcher.instance.addEventListener('requestMarkerUpdate', _onRequestMarkerUpdate);
			VeinDispatcher.instance.addEventListener('requestModelValue', _onRequestModelValue);
			VeinDispatcher.instance.addEventListener('requestCustomTableValue', _onRequestCustomTableValue);
			VeinDispatcher.instance.addEventListener('customTableValueDelete', _onCustomTableDelete);
			VeinDispatcher.instance.addEventListener('customTableValueAdd', _onCustomTableAdd);
			VeinDispatcher.instance.addEventListener('requestSetting', _onRequestSetting);
			VeinDispatcher.instance.addEventListener('requestPopup', _onRequestPopup);
			VeinDispatcher.instance.addEventListener('getMarkerLabel', _onGetMarkerLabel);
			
			
			_setupContextMenu();
		}
		
		private function _enableMouseWheel(event:Event):void {
			MouseWheelEnabler.init( stage );
		}
		
		private function _hideActionBar():void {
			TweenLite.to(actionbar_cvs, 1, {alpha:0, delay:2});
		}
		
		private function _globalExeptionCatcher(event:Event):void {
			try {
				var error:Error = event['error'] as Error;
				trace("Error!\n" + error.getStackTrace());
				Alert.show("There has been an error in the application, an e-mail has been send to the developer", "Error", Alert.OK);
				CommandController.addToQueue(new LogErrorCommand(), error.getStackTrace());
			} catch(ex:Error) {/* Swallow it */
				
				Alert.show("Something went wrong...");
			}
		}
		
		private function _loaded(event:Event):void {
			_iconscomplete = true;
			invalidateProperties();
		}
		
		/**
		 * _onApplicationStateChanged function
		 *  
		 **/
		private function _onApplicationStateChanged(event:Event):void {
			_applicationStateChanged = true;
			invalidateProperties();
		}
		
		/**
		 * _onGetMarkerLabel function
		 *  
		 **/
		private function _onGetMarkerLabel(event:VeinEvent):void {
			CommandController.addToQueue(new GetMarkerLabelCommand(), event.data.markerId, event.data.callback);
		}
		
		/**
		 * _onInspect function
		 *  
		 **/
		private function _onInspect(event:ContextMenuEvent):void {
			var child:DisplayObject = event.currentTarget as DisplayObject;
			enterDebugger();
		}
		
		/**
		 * _onRequestMarkerUpdate function
		 *  
		 **/
		private function _onRequestMarkerUpdate(event:VeinEvent):void {
			CommandController.addToQueue(new GetMarkersAndPolysCommand());
			
		}
		
		/**
		 * _onRequestModelValue function
		 *  
		 **/
		private function _onRequestModelValue(event:VeinEvent):void {
			_modelRequests[event.data.toString()] = event.data.toString();
			_modelRequested = true;
			invalidateProperties();
		}
		
		/**
		 * _onSettingsChanged function
		 * @param event The event  
		 **/
		private function _onSettingsChanged(event:Event):void {
			if(event['data'] == 'pageDivider_NaN')
				return;
			
			_settingsChanged = true;
			invalidateProperties();
		}
		
		/**
		 * _onCustomTableAdd function
		 * @param event The event  
		 **/
		private function _onCustomTableAdd(event:VeinEvent):void {
			CommandController.addToQueue(new AddCustomTableValueCommand(), event.data.table, event.data.labelfield, event.data.name);
		}
		
		/**
		 * _onCustomTableDelete function
		 * @param event The event  
		 **/
		private function _onCustomTableDelete(event:VeinEvent):void {
			CommandController.addToQueue(new DeleteCustomTableValueCommand(), event.data.table, event.data.identifier, event.data.id);
		}
		
		/**
		 * _onRequestCustomTableValue function
		 *  
		 **/
		private function _onRequestCustomTableValue(event:VeinEvent):void {
			if(event.data != null) {
				_customTableValueRequests[event.data.toString()] = event.data.toString();
				_customTableValueRequested = true;
				invalidateProperties();
			}
		}
		
		/**
		 * _onRequestPopup function
		 *  
		 **/
		private function _onRequestPopup(event:VeinEvent):void {
			switch(event.data.popup) {
				case 'markerlist':
					var popup:IFlexDisplayObject = PopUpManager.createPopUp(this, MarkerListPopup, true);
					PopUpManager.centerPopUp(popup);
					MarkerListPopup(popup).filter = event.data.hasOwnProperty('filter') ? event.data.filter : null;
					MarkerListPopup(popup).callback = event.data.callback;
					break;
			}
		}
		
		/**
		 * _onRequestSetting function
		 *  
		 **/
		private function _onRequestSetting(event:VeinEvent):void {
			switch(event.data) {
				case 'maps.visibleColumns':
					if(!Model.instance.administratorVO.getSetting('maps.visibleColumns')) {
						Model.instance.administratorVO.setSetting('maps.visibleColumns', Model.instance.applicationVO.config.columns.maps);
					}
					break;
				case 'element.visibleColumns':
					if(!Model.instance.administratorVO.getSetting('element.visibleColumns')) {
						Model.instance.administratorVO.setSetting('element.visibleColumns', Model.instance.applicationVO.config.columns.element);
					}
					break;
			}
			VeinDispatcher.instance.dispatch('settingsRequestResult', {setting: event.data, value: Model.instance.administratorVO.getSetting(event.data)});
		}
		
		private function _setupContextMenu():void {
			contextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
			
			var prodname:ContextMenuItem = new ContextMenuItem("Bright CMS " + Version.VERSION, false, false);
			var authname:ContextMenuItem = new ContextMenuItem("Product of Fur");
			var inspect:ContextMenuItem = new ContextMenuItem("Inspect Element");
			authname.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _authHandler, false, 0, true);
			inspect.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _onInspect, false, 0, true);
			contextMenu.customItems = [prodname, authname, inspect];
			Application.application.contextMenu = contextMenu;
		}
 
	}
}