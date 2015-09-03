package nl.bs10.bright.views.settings {
	
	
	import flash.events.Event;
	
	import mx.containers.TitleWindow;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class DataGridSettingsView extends TitleWindow {
		
		private var _visibleColumns:String;
		private var _availableColumns:Array;
		
		public function DataGridSettingsView() {
			super();
		}
		
		protected function datagridsettingsview1_closeHandler(event:CloseEvent):void {
			visibleColumns = null;
			availableColumns = null;
			PopUpManager.removePopUp(this);
		}
		
		[Bindable(event="visibleColumnsChanged")]
		public function set visibleColumns($value:String):void {
			if($value !== _visibleColumns) {
				_visibleColumns = $value;
				dispatchEvent(new Event("visibleColumnsChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the visibleColumns property
		 **/
		public function get visibleColumns():String {
			return _visibleColumns;
		}
		
		
		[Bindable(event="availableColumnsChanged")]
		public function set availableColumns($value:Array):void {
			if($value !== _availableColumns) {
				_availableColumns = $value;
				dispatchEvent(new Event("availableColumnsChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the availableColumns property
		 **/
		public function get availableColumns():Array {
			return _availableColumns;
		}
	}
}