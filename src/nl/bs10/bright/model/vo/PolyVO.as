package nl.bs10.bright.model.vo {
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import nl.bs10.bright.commands.maps.SetPolyCommand;
	import nl.bs10.brightlib.interfaces.IContentVO;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.PolyPage;
	import nl.fur.vein.controllers.CommandController;
	
	public class PolyVO extends MultiLangVO implements IContentVO {
		
		private var _currentItem:IPage;
		private var _currentPoly:PolyPage;
		private var _apolys:ArrayCollection = new ArrayCollection();
		private var _polysChanged:Boolean = false;
		
		[Bindable] public var polys:Array = new Array();
		
		public function PolyVO() {
			super();
		}
		
		public function get apolys():ArrayCollection {
			return _apolys;
		}
		
		[Bindable(event="apolysChanged")]
		public function set apolys(value:ArrayCollection):void {
			if(_apolys !== value) {
				_apolys = value;
				dispatchEvent(new Event("apolysChanged"));
			}
		}

		[Bindable(event="ItemChanged")] 
		override public function set currentItem(value:IPage):void {
			if(_currentItem !== value) {
				_currentItem = value as PolyPage;
				currentPoly = value as PolyPage;
				dispatchEvent(new Event("ItemChanged"));
			}
		}
		
		override public function get currentItem():IPage {
			return _currentPoly;
		}

		[Bindable(event="polyChanged")] 
		public function set currentPoly(value:PolyPage):void {
			if(_currentPoly !== value) {
				_currentPoly = value;
				dispatchEvent(new Event("polyChanged"));
			}
		}
		
		public function get currentPoly():PolyPage {
			return _currentPoly;
		}

		public function set polysChanged(value:Boolean):void {
			_polysChanged = value;
			var arr:Array = new Array();
			for each(var co:IPage in polys) {
				arr.push(co);
			}
			var s:Sort = apolys.sort;
			apolys = new ArrayCollection(arr);
			apolys.sort = s;
			apolys.refresh();
		} 
		
		public function get polysChanged():Boolean {
			return _polysChanged;
		}
		
		override public function save(callback:Function):void {
			CommandController.addToQueue(new SetPolyCommand(), currentItem, callback);
		}
	}
}