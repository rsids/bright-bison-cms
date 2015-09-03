package nl.bs10.bright.model.vo {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import nl.bs10.bright.commands.elements.SetElementCommand;
	import nl.bs10.brightlib.interfaces.IContentVO;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.controllers.CommandController;
	
	public class ElementVO extends MultiLangVO implements IContentVO {
		
		private var _currentItem:IPage;
		private var _aelements:ArrayCollection = new ArrayCollection();
		private var _totalElements:int = 0;
		
		public var filter:String;
		
		[Bindable] public var elements:Array = new Array();

		public var elementsFetched:Boolean = false;
		public var elementHashmap:Array;
		
		public function get aelements():ArrayCollection {
			return _aelements;
		}
		
		private var _elementsChanged:Boolean = false;
	
		public function set elementsChanged(value:Boolean):void {
			_elementsChanged = value;
			var arr:Array = new Array();
			for each(var co:Page in elements) {
				arr.push(co);
			}
			var s:Sort = aelements.sort;
			var fn:Function;
			if(aelements && aelements.filterFunction != null);
				fn = aelements.filterFunction;
				
			aelements = new ArrayCollection(arr);
			aelements.filterFunction = fn;
			aelements.sort = s;
			aelements.refresh();
		} 
		
		public function get elementsChanged():Boolean {
			return _elementsChanged;
		}
		
		[Bindable(event="aelementsChanged")]
		public function set aelements(value:ArrayCollection):void {
			if(_aelements !== value) {
				_aelements = value;
				dispatchEvent(new Event("aelementsChanged"));
			}
		}

		[Bindable(event="ItemChanged")] 
		override public function set currentItem(value:IPage):void {
			if(_currentItem !== value) {
				_currentItem = value;
				dispatchEvent(new Event("ItemChanged"));
			}
		}
		
		override public function get currentItem():IPage {
			return _currentItem;
		}
		
		override public function save(callback:Function):void {
			CommandController.addToQueue(new SetElementCommand(), currentItem, callback);
		}
		
		[Bindable(event="totalElementsChanged")]
		public function set totalElements(value:int):void {
			if(value !== _totalElements) {
				_totalElements = value;
				dispatchEvent(new Event("totalElementsChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the totalElements property
		 **/
		public function get totalElements():int {
			return _totalElements;
		}
	}
}