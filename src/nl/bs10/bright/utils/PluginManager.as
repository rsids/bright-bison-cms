package nl.bs10.bright.utils {
	
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.elements.GetElementsByIdCommand;
	import nl.bs10.bright.commands.tree.GetPathCommand;
	import nl.bs10.bright.views.elements.ElementPopupViewLayout;
	import nl.bs10.bright.views.maps.LayerPopupViewLayout;
	import nl.bs10.bright.views.modules.ModulePopupView;
	import nl.bs10.bright.views.structure.LinkPopupView;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.fur.vein.controllers.CommandController;
	
	public class PluginManager {
		private static var _explorer:UIComponent;
		private static var _maps:UIComponent;
		private static var _link:UIComponent;
		
		private static var _modules:Dictionary = new Dictionary();
		
		public function PluginManager() {
		}
		
		public static function getMaps():UIComponent {
			return PluginManager._maps;
		}
		
		public static function setMaps(value:UIComponent):void {
			PluginManager._maps = value;
		}
		
		public static function getExplorer():UIComponent {
			return PluginManager._explorer;
		}
		
		public static function setExplorer(value:UIComponent):void {
			PluginManager._explorer = value;
		}
		
		public static function getLinkChooser():UIComponent {
			return PluginManager._link;
		}
		
		public static function setLinkChooser(value:UIComponent):void {
			PluginManager._link = value;
		}
		
		public static function setModule(value:UIComponent, moduleName:String):void {
			_modules[moduleName] = value;
		}
		
		public static function getModule(moduleName:String):UIComponent {
			if(!_modules.hasOwnProperty(moduleName)) {
				Alert.show(moduleName + " not found", "Cannot load module");
				return null;
			}
			return _modules[moduleName];
		}
		
		public static function handleDataEvent(event:BrightEvent):void {
			switch(event.data.type) {
		 		case 'openElementExplorer':
		 			var epv:IFlexDisplayObject = PopUpManager.createPopUp( Application.application as DisplayObject,
		 																	ElementPopupViewLayout,
		 																	true);
		 			(epv as ElementPopupViewLayout).multiple = event.data.multiple;
		 			(epv as ElementPopupViewLayout).filter = event.data.hasOwnProperty('filter') ? event.data.filter : null;
		 			(epv as ElementPopupViewLayout).callback = event.data.callback;
					PopUpManager.centerPopUp(epv);
		 			break;
		 		case 'openLayerExplorer':
		 			var lpv:IFlexDisplayObject = PopUpManager.createPopUp( Application.application as DisplayObject,
		 																	LayerPopupViewLayout,
		 																	true);
		 			(lpv as LayerPopupViewLayout).multiple = event.data.multiple;
		 			(lpv as LayerPopupViewLayout).callback = event.data.callback;
					PopUpManager.centerPopUp(lpv);
		 			break;
		 		case 'getElementsById':
		 			CommandController.addToQueue(new GetElementsByIdCommand(), event.data.pageIds, event.data.callback);
		 			break;
				
				case 'openLinkChooser':
					var p:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject,
						LinkPopupView,
						true);
					LinkPopupView(p).setProperties(event.data);
					PopUpManager.centerPopUp(p);
					break;
		 		
		 		case 'toggleFullscreen':
		 			if(event.data.toggle) {
		 				
		 			} else {
		 				
		 			}
		 			break;
		 		case 'getPathForTid':
		 			CommandController.addToQueue(new GetPathCommand(), event.data.tid, event.data.callback);
		 			break;
		 			//{type:"getPathForTid", callback:setRealPath, tid:pa[1]}
		 		case 'openModule':
		 			var mpv:ModulePopupView = PopUpManager.createPopUp(Application.application as DisplayObject,
		 																	ModulePopupView,
		 																	true) as ModulePopupView;
		 			if(!event.data.hasOwnProperty("callback")) {
		 				Alert.show("A callback is required for the openModule event");
		 				return;
		 			}
		 			if(!event.data.hasOwnProperty("module")) {
		 				Alert.show("A module is required for the openModule event");
		 				return;
		 			}
		 			mpv.callback = event.data.callback;
		 			mpv.module = event.data.module;
		 			if(event.data.hasOwnProperty("title"))
		 				mpv.title = event.data.title;
		 			if(event.data.hasOwnProperty("params"))
		 				mpv.params = event.data.params;
					PopUpManager.centerPopUp(mpv);
		 	}
		}

	}
}