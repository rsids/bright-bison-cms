package nl.bs10.bright.components {
	import flash.events.Event;
	
	import mx.containers.DividedBox;
	import mx.events.DividerEvent;
	
	import nl.bs10.bright.model.Model;
	
	public class BrightDividedBox extends DividedBox {
		
		private var _oldWidth:Number;
		
		
		private var _dividername:String;
		private var _dividernameChanged:Boolean;
		
		public function BrightDividedBox()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, _onAdd, false, 0, true);
			addEventListener(DividerEvent.DIVIDER_RELEASE, _onDividerRelease, false, 0, true);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_dividernameChanged) {
				_dividernameChanged = false;
				var dw:int = Number(Model.instance.administratorVO.getSetting(dividername + "_" +  _oldWidth));
				if(!isNaN(dw) && dw > 0) {
					this.getChildAt(0).width = dw;
				} else {
					// Save state
					Model.instance.administratorVO.setSetting(dividername + "_" +  _oldWidth, getChildAt(0).width);
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(stage.stageWidth != _oldWidth) {
				_oldWidth = stage.stageWidth;
				_dividernameChanged = true;
				invalidateProperties();
			}
		}
		
		
		[Bindable(event="dividernameChanged")]
		public function set dividername(value:String):void {
			if(value !== _dividername) {
				_dividername = value;
				_dividernameChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("dividernameChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the dividername property
		 **/
		public function get dividername():String {
			return _dividername;
		}

		
		/**
		 * _onAdd function
		 *  
		 **/
		private function _onAdd(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAdd);
		}
		
		/**
		 * _onDividerRelease function
		 *  
		 **/
		private function _onDividerRelease(event:DividerEvent):void {
			Model.instance.administratorVO.setSetting(dividername + "_" +  _oldWidth, getChildAt(0).width + event.delta);
		}
	}
}