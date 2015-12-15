package nl.bs10.bright.model.vo {
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import nl.bs10.bright.commands.maps.SetMarkerCommand;
	import nl.bs10.brightlib.interfaces.IContentVO;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.Layer;
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.fur.vein.controllers.CommandController;
	
	public class MarkerVO extends MultiLangVO implements IContentVO {
		
		private var _currentItem:IPage;
		private var _currentMarker:MarkerPage;
		private var _amarkers:ArrayCollection = new ArrayCollection();
		private var _alayers:ArrayCollection = new ArrayCollection();
		private var _markersChanged:Boolean = false;
		private var _layersChanged:Boolean = false;
		
		public var layersFetched:Boolean = false;
		
		[Bindable] public var markers:Array = new Array();
		[Bindable] public var layers:Array = new Array();
		
		public function MarkerVO() {
			super();
		}
		
		
		public function get alayers():ArrayCollection {
			return _alayers;
		}
		
		[Bindable(event="alayersChanged")]
		public function set alayers(value:ArrayCollection):void {
			if(_alayers !== value) {
				_alayers = value;
				dispatchEvent(new Event("alayersChanged"));
			}
		}
		
		public function get amarkers():ArrayCollection {
			return _amarkers;
		}
		
		[Bindable(event="amarkersChanged")]
		public function set amarkers(value:ArrayCollection):void {
			if(_amarkers !== value) {
				_amarkers = value;
				dispatchEvent(new Event("amarkersChanged"));
			}
		}

		[Bindable(event="ItemChanged")] 
		override public function set currentItem(value:IPage):void {
			if(_currentItem !== value) {
				_currentItem = value as MarkerPage;
				currentMarker = value as MarkerPage;
				dispatchEvent(new Event("ItemChanged"));
			}
		}
		
		override public function get currentItem():IPage {
			return _currentMarker;
		}

		[Bindable(event="markerChanged")] 
		public function set currentMarker(value:MarkerPage):void {
			if(_currentMarker !== value) {
				_currentMarker = value;
				dispatchEvent(new Event("markerChanged"));
			}
		}
		
		public function get currentMarker():MarkerPage {
			return _currentMarker;
		}

		public function set markersChanged(value:Boolean):void {
			_markersChanged = value;
			var arr:Array = new Array();
			for each(var co:IPage in markers) {
				arr.push(co);
			}
			
			var s:Sort = amarkers.sort;
			amarkers = new ArrayCollection(arr);
			amarkers.sort = s;
			amarkers.refresh();
		} 
		
		public function get markersChanged():Boolean {
			return _markersChanged;
		}

		public function set layersChanged(value:Boolean):void {
			_layersChanged = value;
			var arr:Array = new Array();
			for each(var co:Layer in layers) {
				arr.push(co);
			}
			var s:Sort = alayers.sort;
			alayers = new ArrayCollection(arr);
			alayers.sort = s;
			alayers.refresh();
		} 
		
		public function get layersChanged():Boolean {
			return _layersChanged;
		}
		
		override public function save(callback:Function):void {
			CommandController.addToQueue(new SetMarkerCommand(), currentItem, callback);
		}
	}
}