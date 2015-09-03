package nl.bs10.bright.views.renderers {
	
	import mx.containers.HBox;
	import mx.controls.Label;
	import mx.controls.TextInput;

	public class NumberPropertyRenderer extends HBox implements IPropertyRenderer {
		private var _label:Label = new Label();
		private var _input:TextInput = new TextInput();
		
		override protected function createChildren():void {
			super.createChildren();
			_label.width = 170;
			_input.percentWidth = 100;
			
			addChild(_label);
			addChild(_input);
			_input.restrict = "[0-9,.]";
		}	
		
		override public function set label(value:String):void {
			super.label = _label.text = value;
		}
		
		public function set property(value:*):void {
			_input.text = value.toString();
		}
		
		public function get property():* {
			return (_input.text == "") ? null :  Number(_input.text);
		}
		
	}
}