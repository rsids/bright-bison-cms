package nl.bs10.bright.views.renderers {
	
	import mx.containers.HBox;
	import mx.controls.Label;
	import nl.bs10.brightlib.components.renderers.IconRenderer;

	public class TemplateDefRenderer extends HBox {
		private var _icon_ir:IconRenderer =  new IconRenderer();
		private var _label_txt:Label = new Label();
		
		public function TemplateDefRenderer() {
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			addChild(_icon_ir);
			addChild(_label_txt);
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			_icon_ir.data = value;
			if(!value)
				return;
			
			_label_txt.text = value.templatename;
		}
		
	}
}