package nl.bs10.bright.views.renderers {
	
	import mx.containers.HBox;
	import mx.controls.Label;
	import mx.core.ScrollPolicy;
	
	import nl.bs10.brightlib.components.renderers.IconRenderer;

	public class LocationRenderer extends HBox {
		private var _icon_ir:IconRenderer;
		private var _label_txt:Label;
		
		public function LocationRenderer() {
			super();
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			
			mouseChildren = false;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_icon_ir = new IconRenderer();
			_label_txt = new Label();
			
			_label_txt.percentWidth = 100;
			_label_txt.truncateToFit = true;
			
			addChild(_icon_ir);
			addChild(_label_txt);
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			_icon_ir.data = value;
			if(!value)
				return;
			
			_label_txt.text = value.label;
		}
		
	}
}