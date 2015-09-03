package nl.bs10.bright.components
{
	import flash.events.Event;
	
	import mx.events.ScrollEvent;
	
	[Event(name="bottomReached", type="flash.events.Event")]
	public class LazyDataGrid extends BrightDataGrid {
		
		private var _oldMax:int = -1;
		
		public function LazyDataGrid() {
			super();
			addEventListener(ScrollEvent.SCROLL, _checkScroll, false, 0, true);
			
		}
		
		override public function set dataProvider(value:Object):void {
			super.dataProvider = value;
			_oldMax = -1;
		}
		
		/**
		 * _checkScroll function
		 * @param event The event  
		 **/
		private function _checkScroll(event:ScrollEvent):void {
			
			if(event.position == verticalScrollBar.maxScrollPosition && _oldMax != verticalScrollBar.maxScrollPosition) {
				_oldMax = verticalScrollBar.maxScrollPosition;
				dispatchEvent(new Event('bottomReached'));
			}
		}
	}
}