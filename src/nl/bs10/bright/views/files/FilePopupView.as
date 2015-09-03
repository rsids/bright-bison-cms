package nl.bs10.bright.views.files {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.TitleWindow;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.controllers.PermissionController;
	import nl.bs10.bright.utils.PluginManager;
	import nl.bs10.brightlib.events.FileExplorerEvent;

	public class FilePopupView extends TitleWindow {
		
		private var _explorer:DisplayObject;
		
		public function FilePopupView() {
			super();
			width = 950;
			height = 550;
			layout = "absolute";
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, _close, false, 0, true);
			
			title = "Select File(s)";
			removeAllChildren();	
			_explorer = PluginManager.getExplorer();
			_explorer.x = 0;
			_explorer.y = 0;
			addChild(_explorer);
		}
		
		public function setProperties(event:FileExplorerEvent):void {
			width = (event.foldersOnly) ? 310 : 950;
			_explorer["child"].setProperties(event.callback, true, event.multiple, event.filter, PermissionController.instance._UPLOAD_FILE, PermissionController.instance._DELETE_FILE, event.foldersOnly);
			_explorer["child"].addEventListener("closePopup", _close, false, 0, true);
		}
		
		private function _close(event:Event):void {
			PopUpManager.removePopUp(this);
		}
		
	}
}