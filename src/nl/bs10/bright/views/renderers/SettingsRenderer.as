package nl.bs10.bright.views.renderers {
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;
	
	import nl.bs10.bright.commands.config.DeleteSettingCommand;
	import nl.bs10.brightlib.components.GrayImageButton;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.flexperiments.text.AutoSizeText;
	import nl.fur.vein.controllers.CommandController;

	public class SettingsRenderer extends HBox
	{
		private var _label_lbl:Label;
		private var _label_txt:TextInput;
		private var _value_txt:AutoSizeText;
		private var _delete_btn:GrayImageButton;
		
		private var _data:Object;
		private var _isnew:Boolean;
		private var _isnewchanged:Boolean;
		private var _datachanged:Boolean;
		
		
		public function SettingsRenderer() {
			super();
			setStyle("paddingLeft", 5);
			setStyle("paddingRight", 5);
			setStyle("paddingTop", 5);
			setStyle('verticalAlign', 'middle'); 
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_label_lbl = new Label();
			_label_txt = new TextInput();
			_value_txt = new AutoSizeText();
			_delete_btn = new GrayImageButton();
			
			_label_lbl.width = 200
			_label_txt.width = 200;
			_value_txt.width = 241;
			
			_value_txt.autoResize = true;
			
			_label_txt.restrict = "[a-z_]";
			
			_delete_btn.source = IconController.getIcon('delete');
			_delete_btn.addEventListener(MouseEvent.CLICK, _deleteClickHandler, false, 0, true);
			_delete_btn.buttonMode =
			_delete_btn.useHandCursor = true;
			
			addChild(_label_lbl);
			addChild(_label_txt);
			addChild(_value_txt);
			addChild(_delete_btn);
		}
		
		public function set isnew(value:Boolean):void {
			_isnew = value;
			_isnewchanged = true;
			invalidateProperties();
		}
		
		public function get isnew():Boolean {
			return _isnew;
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			if(!value)
				return;
			_data  = value;
			_datachanged = true;
			invalidateProperties();
		}
		
		override public function get data():Object {
			return {name:_label_txt.text, value:_value_txt.text};
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_isnewchanged) {
				_isnewchanged = false;
				_label_lbl.includeInLayout =
				_label_lbl.visible = !isnew;
				
				_label_txt.includeInLayout =
				_label_txt.visible = isnew;
			}
			
			if(_datachanged) {
				_datachanged = false;
				_label_lbl.text =
				_label_txt.text = _data.name;
				
				_value_txt.text = _data.value;
				//invalidateDisplayList();
			}
			
			
		}
		
		private function _deleteClickHandler(event:MouseEvent):void {
			if(isnew) {
				parent.removeChild(this);
				return;
			}
			Alert.show("Are you sure you want to delete this setting?", "Please Confirm", Alert.YES|Alert.CANCEL, null, _deleteHandler);
		}
		
		private function _deleteHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES)
				CommandController.addToQueue(new DeleteSettingCommand(), this);
		}
	}
}