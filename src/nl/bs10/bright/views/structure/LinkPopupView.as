package nl.bs10.bright.views.structure
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.TitleWindow;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.utils.PluginManager;

	public class LinkPopupView extends TitleWindow {
		
		private var _link:DisplayObject;
		private var _propertieschanged:Boolean;
		private var _properties:Object;
		
		public function LinkPopupView() {
			super();
			width = 500;
			height = 555;
			horizontalScrollPolicy = "off";
			verticalScrollPolicy = "off";
			layout = "absolute";
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, _close, false, 0, true);
			title = "Enter link";
		}
		
		override protected function createChildren():void {
			super.createChildren();
			_link = PluginManager.getLinkChooser();
			_link.y = 0;
			_link.x = 0;
			_link.width = width - 25;
			_link.height = height - 25;
			addChild(_link);
		}
		
		private function _close(event:Event):void {
			PopUpManager.removePopUp(this);
		}
		
		public function setProperties(properties:Object):void {
			_properties = properties;
			_propertieschanged = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(!_propertieschanged)
				return;
				
			_link["child"].setProperties(_properties);
			_link["child"].removeEventListener("closePopup", _close);
			_link["child"].addEventListener("closePopup", _close, false, 0, true);
			
			_propertieschanged = false;
			_properties = null;
				
		}
	}
}