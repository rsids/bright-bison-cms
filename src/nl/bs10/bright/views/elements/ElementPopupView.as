package nl.bs10.bright.views.elements
{
	import com.adobe.utils.ArrayUtil;
	
	import flash.events.Event;
	
	import mx.containers.Panel;
	import mx.controls.DataGrid;
	import mx.formatters.DateFormatter;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.elements.GetElementsCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.fur.vein.controllers.CommandController;

	public class ElementPopupView extends Panel {
		
		private var _multiple:Boolean;
		private var _filter:Array;
		private var _filterChanged:Boolean;
		
		public var callback:Function;
		
		[Bindable] public var element_dg:DataGrid;
		
		public function ElementPopupView() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, _init);
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
		
		public function set filter(value:Array):void {
			if(value !== _filter) {
				_filter = value;
				_filterChanged = true;
				invalidateProperties()
			}
		}
		
		public function get filter():Array {
			return _filter;
		}
		
		protected function close():void {
			callback = null;
			filter = null;
			PopUpManager.removePopUp(this);
		}
		
		protected function addElements():void{
			callback(element_dg.selectedItems);
			close();
		}
		
		private function _init(event:Event):void {
			CommandController.addToQueue(new GetElementsCommand());
		}
		
		/**
		 * @todo These methods are copied over and over again, make a static method of it!
		 */
		protected function date_formatter(data:Object, column:Object):String {
			var f:DateFormatter = new DateFormatter();
            f.formatString = "DD-MM-YYYY J:NN";
            return f.format(data[column.dataField]);
		}
		
		protected function sortByType(a:Object, b:Object):int {
			return (a.itemType > b.itemType) ? 1 : -1;
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_filterChanged) {
				_filterChanged = false;
				if(!filter || filter.length == 0) {
					Model.instance.elementVO.aelements.filterFunction = null;
				} else {
					Model.instance.elementVO.aelements.filterFunction = _elementFilter;
				}
				Model.instance.elementVO.aelements.refresh();
				//Model.instance.elementVO.dispatchEvent(new Event("aelementsChanged"));
			}
		}
		
		private function _elementFilter(el:IPage):Boolean {
			var c:Boolean = ArrayUtil.arrayContainsValue(filter, el.itemType.toString());
			return c;
		}
	}
}