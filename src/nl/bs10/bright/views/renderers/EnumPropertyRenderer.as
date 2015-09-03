package nl.bs10.bright.views.renderers {
	
	import flash.events.Event;
	
	import mx.containers.HBox;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.events.ListEvent;

	public class EnumPropertyRenderer extends HBox implements IPropertyRenderer {
		private var _label:Label;
		private var _input:ComboBox;
		private var _labelChanged:Boolean = false;
		private var _slabel:String;
		
		private var _enum:Array;
		private var _enumChanged:Boolean;
		
		private var _property:*;
		private var _propertyChanged:Boolean;
		
		function EnumPropertyRenderer() {
			percentWidth = 100;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_label = new Label();
			_input = new ComboBox();
			_input.addEventListener(ListEvent.CHANGE, _onInputChange, false, 0, true);
			_input.percentWidth = 100;
			_label.width = 170;
			
			addChild(_label);
			addChild(_input);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_labelChanged) {
				_label.text = label;
			}
			if(_enumChanged) {
				_enumChanged = false;
				_input.dataProvider = enum;
				_input.selectedIndex = -1;
			}
			if(_propertyChanged && enum && enum.length > 0) {
				_propertyChanged = false;
				for(var i:int = 0; i < enum.length; i++) {
					if(enum[i] == property) {
						_input.selectedIndex = i;
					}
				}
			}
		}
		
		/**
		 * _onInputChange function
		 * @param event The event  
		 **/
		private function _onInputChange(event:Event):void {
			if(_input.selectedItem) {
				_property = _input.selectedItem.toString();
			} else {
				_property = null;
			}
		}
		
		override public function set label(value:String):void {
			super.label = value;
			_labelChanged = true;
			invalidateProperties();
		}
		
		
		[Bindable(event="propertyChanged")]
		public function set property(value:*):void {
			if(value !== _property) {
				_property = value;
				_propertyChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("propertyChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the property property
		 **/
		public function get property():* {
			return _property;
		}
		
		[Bindable(event="enumChanged")]
		public function set enum(value:Array):void {
			if(value !== _enum) {
				_enum = value;
				_enumChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("enumChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the enum property
		 **/
		public function get enum():Array {
			return _enum;
		}
		
	}
}