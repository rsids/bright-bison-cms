package nl.bs10.bright.views.renderers {
	
	import mx.containers.HBox;
	import mx.controls.CheckBox;
	import mx.controls.Label;
	import mx.controls.TextInput;

	public class BooleanPropertyRenderer extends HBox implements IPropertyRenderer {
		private var _label:Label = new Label();
		private var _input:CheckBox = new CheckBox();
		
		override protected function createChildren():void {
			super.createChildren();
			_label.width = 170;
			
			addChild(_label);
			addChild(_input);
		}	
		
		override public function set label(value:String):void {
			super.label = _label.text = value;
		}
		
		public function set property(value:*):void
		{
			_input.selected = value.toString() == "true";
		}
		
		public function get property():*
		{
			return _input.selected;
		}
		
	}
}