package nl.bs10.bright.views.renderers {
	import com.adobe.serialization.json.JSON;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.events.ListEvent;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.PluginProperties;

	public class FieldRenderer extends Canvas {
		
		[Bindable] public var label_txt:TextInput;
		[Bindable] public var displaylabel_txt:TextInput;
		[Bindable] public var searchable_chb:CheckBox;
		[Bindable] public var type_cmb:ComboBox;
		[Bindable] public var data_vb:VBox;
		
		private var _data:Object;
		private var _created:Boolean;
		
		public function FieldRenderer()
		{
			super();
		}
		
		[Bindable]
		override public function set data(value:Object):void {
			super.data = value;
			if(!value)
				return;
				
			_data = value;
			_setup();
		}
		
		/**
		 * Returns the properties of the plugin
		 * @todo Report an error when no selection was made
		 * @return Object 
		 * 
		 */		
		override public function get data():Object {
			if(!_created)
				return super.data;
			
			if(!_data)
				_data = {};
				
			_data.label = label_txt.text;
			_data.displaylabel = displaylabel_txt.text;
			_data.searchable = searchable_chb.selected;
			if(type_cmb.selectedItem) {
				_data.type = type_cmb.selectedItem.type;
				_data.contenttype = type_cmb.selectedItem.contenttype
				var children:Array = data_vb.getChildren();
				var adddata:Object = {};
				for each(var prop:IPropertyRenderer in children) {
					if(prop.property != null)
						adddata[prop.label] = prop.property;
				}
				_data.data = JSON.encode(adddata);
			}
			return _data;
		}
		
		protected function moveItem(direction:Number):void {
			var type:String = (direction == 1) ? "MOVE_DOWN" : "MOVE_UP";
			dispatchEvent(new Event(type));
		}
		
		protected function deleteItem():void {
			parent.removeChild(this);
		}
		
		protected function creationCompleteHandler():void {
			_created = true;
			_setup();
		}
		
		protected function setFieldType(event:ListEvent):void {
			_setProperties();
		}
		
		protected function checkDigit():void {
			var lbl:String = label_txt.text;
			var needchecking:Boolean = true;
			while(lbl.length != 0 && needchecking) {
				if((lbl.charCodeAt(0) > 47 && lbl.charCodeAt(0) < 58) || lbl.charCodeAt(0) == 45 || lbl.charCodeAt(0) == 95) {
					lbl = lbl.substr(1);
				} else {
					needchecking = false;
				}
			}
			label_txt.text = lbl;
		}
		
		private function _setup():void {
			if(!_data || !_created)
				return;
			
			label_txt.text = _data.label;
			displaylabel_txt.text = _data.displaylabel;
			searchable_chb.selected = _data.searchable;
			
			for each(var fieldtype:PluginProperties in Model.instance.templateVO.fieldTypes) {
				if(fieldtype.type == _data.type) {
					type_cmb.selectedItem = fieldtype;
					_setProperties();
					break;
				}
			}
		}
		
		
		/**
		 * @todo Fix _setProperties 
		 * 
		 */		
		private function _setProperties():void {
			data_vb.removeAllChildren();
			if(!type_cmb.selectedItem)
				return;
				
			var fieldtype:PluginProperties = type_cmb.selectedItem as PluginProperties;
			for each(var prop:Object in fieldtype.properties) {
				var propren:IPropertyRenderer;
				switch(prop.type) {
					case "string":
						propren = new StringPropertyRenderer();
						break;
					case "array":
						propren = new ArrayPropertyRenderer();
						break;
					case "boolean":
						propren = new BooleanPropertyRenderer();
						break;
					case "number":
						propren = new NumberPropertyRenderer();
						break;
					case "enum":
						propren = new EnumPropertyRenderer();
						propren['enum'] = prop.values;
						break;
					default:
						Alert.show("Unknown property type '" + prop.type + "'", "Unknown property");
				}
				if(propren) {
					propren.label = prop.name;
					data_vb.addChild(propren as DisplayObject);
					if(_data && _data.data && _data.data != "") {
						var datobj:Object = JSON.decode(_data.data);
						if(datobj.hasOwnProperty(prop.name))
							propren.property = datobj[prop.name];
					}
				}
			}
		}
		
	}
}