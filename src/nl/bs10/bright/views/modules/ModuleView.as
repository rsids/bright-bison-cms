package nl.bs10.bright.views.modules
{
	import flash.display.DisplayObject;
	
	import mx.containers.Canvas;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.utils.PluginManager;
	import nl.bs10.bright.views.files.FilePopupView;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.events.FileExplorerEvent;
	import nl.bs10.brightlib.interfaces.IModule;

	public class ModuleView extends Canvas
	{
		public var plugin:UIComponent;
		
		public function ModuleView()
		{
			super();
			percentWidth = 100;
			percentHeight = 100;
		}
		
		public function loadModule(moduleName:String):void {
			unload();
			plugin = PluginManager.getModule(moduleName);
			plugin.percentWidth = 100;
			plugin.percentHeight = 100;
			plugin.x = 0;
			plugin.y = 0;
			plugin["styleName"] = "borderedBox";
			plugin["child"].addEventListener(FileExplorerEvent.OPENFILEEXPLOREREVENT, _openFileExplorer, false, 0, true);
			plugin["child"].addEventListener(BrightEvent.DATAEVENT, _dataEventHandler, false, 0, true);
			addChild(plugin); 
			if(plugin["child"] is IModule) {
				IModule(plugin["child"]).initializeModule();
			}
		}
		
		public function unload():void {
			if(plugin) {
				plugin["child"].removeEventListener(FileExplorerEvent.OPENFILEEXPLOREREVENT, _openFileExplorer);
				plugin["child"].removeEventListener(BrightEvent.DATAEVENT, _dataEventHandler);
			}
			removeAllChildren();
		}
		
		public function setModuleParams(params:Object):void {
			if(plugin) {
				plugin["child"].params = params;
			}
		}
		
		private function _openFileExplorer(event:FileExplorerEvent):void {
			var p:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject,
																FilePopupView,
																true);
			FilePopupView(p).setProperties(event);
			PopUpManager.centerPopUp(p);
		}
		
		private function _dataEventHandler(event:BrightEvent):void {
			PluginManager.handleDataEvent(event);
		}
		
	}
}