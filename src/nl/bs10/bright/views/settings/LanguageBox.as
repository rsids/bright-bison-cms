package nl.bs10.bright.views.settings
{
	import flash.events.Event;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextInput;
	
	import nl.bs10.bright.model.Model;
	
	public class LanguageBox extends VBox
	{
		
		public var lang_lbl:Label;
		public var lang_img:Image;
		public var header_hb:HBox;
		
		private var _lang:String;
		private var _langChanged:Boolean;
		private var _localizablefieldsChanged:Boolean;
		
		public function LanguageBox()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, _init);
			horizontalScrollPolicy = "off";
			verticalScrollPolicy = "off";
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			styleName = 'borderedBox';
			setStyle('verticalGap', 2);
			lang_img = new Image();
			lang_img.width = lang_img.height = 16;
			
			lang_lbl = new Label();
			lang_lbl.percentWidth = 100;
			lang_lbl.styleName = 'h3';
			
			header_hb = new HBox();
			header_hb.setStyle('verticalAlign', 'middle');
			header_hb.percentWidth = 100;
			
			header_hb.addChild(lang_img);
			header_hb.addChild(lang_lbl);
			
			addChild(header_hb);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_langChanged) {
				_langChanged = false;
				lang_lbl.text = Model.instance.applicationVO.langlabels[lang];
				lang_img.source = Model.instance.applicationVO.langimages[lang];
			}
			
			if(_localizablefieldsChanged) {
				_localizablefieldsChanged = false;
				var index:int = 1;

				index = 1;
				for each(var field:Object in Model.instance.applicationVO.localizablefields[lang]) {
					if(numChildren -1 < index)
						addChild(new TextInput());
					
					var lbl:TextInput = getChildAt(index) as TextInput;
					lbl.text = field.value;
					lbl.data = field.field;
					lbl.percentWidth = 100;
					index++;
				}
				// Clean up!
				while(numChildren > Model.instance.applicationVO.localizablefields[lang].length + 1) {
					removeChildAt(numChildren -1);
				}
					
			}
		}

		public function get lang():String
		{
			return _lang;
		}

		public function set lang(value:String):void
		{
			if(_lang != value) {
				_lang = value;
				_langChanged = true;
				invalidateProperties();
			}
		}
		
		private function _init(event:Event):void {
			Model.instance.applicationVO.addEventListener("localizablefieldsChanged", _localizablefieldsChangedHandler);
		}
		
		private function _localizablefieldsChangedHandler(event:Event = null):void {
			_localizablefieldsChanged = true;
			invalidateProperties();
		}

	}
}