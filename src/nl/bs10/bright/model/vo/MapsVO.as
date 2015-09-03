package nl.bs10.bright.model.vo {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import nl.fur.vein.events.VeinDispatcher;
	
	public class MapsVO extends EventDispatcher {
		
		private var _items:ArrayCollection;
		
		[Bindable(event="itemsChanged")]
		public function set items(value:ArrayCollection):void {
			if(value !== _items) {
				_items = value;
				dispatchEvent(new Event("itemsChanged"));
				// Dispatch veinevent so plugins get notified
				VeinDispatcher.instance.dispatch('markersUpdate', _items);
			}
		}
		
		/** 
		 * Getter/Setter methods for the items property
		 **/
		public function get items():ArrayCollection {
			return _items;
		}
	}
}