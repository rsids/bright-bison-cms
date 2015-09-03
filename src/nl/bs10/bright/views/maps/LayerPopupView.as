package nl.bs10.bright.views.maps
{
	import flash.events.Event;
	
	import mx.containers.Panel;
	import mx.controls.DataGrid;
	import mx.formatters.DateFormatter;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.maps.GetLayersCommand;
	import nl.fur.vein.controllers.CommandController;

	public class LayerPopupView extends Panel {
		
		private var _multiple:Boolean;
		
		public var callback:Function;
		
		[Bindable] public var layers_dg:DataGrid;
		
		public function LayerPopupView() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, _init);
		}
		
		protected function close():void {
			callback = null;
			PopUpManager.removePopUp(this);
		}
		
		protected function addLayers():void{
			callback(layers_dg.selectedItems);
			close();
		}
		
		private function _init(event:Event):void {
			CommandController.addToQueue(new GetLayersCommand());
		}
		
		[Bindable(event="multipleChanged")]
		public function set multiple(value:Boolean):void {
			if(value !== _multiple) {
				_multiple = value;
				dispatchEvent(new Event("multipleChanged"));
			}
		}
		
		public function get multiple():Boolean {
			return _multiple;
		}
	}
}