package nl.bs10.bright.views.renderers {
	
	import mx.containers.HBox;
	import mx.controls.Label;
	import mx.controls.TextInput;

	public class ArrayPropertyRenderer extends HBox implements IPropertyRenderer {
		private var _label:Label = new Label();
		private var _input:TextInput = new TextInput();
		
		private var _slabel:String;
		
		function ArrayPropertyRenderer() {
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
		
		
		public function set property(value:*):void {
			try {
				if(value is Array)
					value = value.join(',');
					
				_input.text = value.toString();
			} catch(ex:Error) {
				_input.text = '';
			}
			
		}
		
		public function get property():* {
			if(_input.text == "")
				return null;
				
			return _input.text.split(',');
		}
		
	}
}