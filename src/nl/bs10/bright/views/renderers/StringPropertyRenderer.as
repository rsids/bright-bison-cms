package nl.bs10.bright.views.renderers {
	
	import mx.containers.HBox;
	import mx.controls.Label;
	import mx.controls.TextInput;

	public class StringPropertyRenderer extends HBox implements IPropertyRenderer {
		private var _label:Label = new Label();
		private var _input:TextInput = new TextInput();
		
		private var _slabel:String;
		
		function StringPropertyRenderer() {
			percentWidth = 100;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			_label.width = 170;
			_input.percentWidth = 100;
			
			addChild(_label);
			addChild(_input);
		}	
		
		override public function set label(value:String):void {
			super.label = 
			_label.text = value;
		}
		
		
		public function set property(value:*):void
		{
			_input.text = value.toString();
		}
		
		public function get property():*
		{
			return (_input.text == "") ? null : _input.text;
		}
		
	}
}