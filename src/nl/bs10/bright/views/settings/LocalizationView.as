package nl.bs10.bright.views.settings
{
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.containers.HDividedBox;
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import nl.bs10.bright.commands.config.GetLocalizableCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.controllers.CommandController;
	
	public class LocalizationView extends HDividedBox
	{
		private var _langsChanged:Boolean;
		private var _localizablefieldsChanged:Boolean;
		private var _fieldsChanged:Boolean;
		
		public var names_vb:VBox;
		
		public function LocalizationView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, _init);
		}
		
		private function _init(event:Event):void {
			Model.instance.applicationVO.addEventListener("langsChanged", _langsChangedHandler);
			Model.instance.applicationVO.addEventListener("localizablefieldsChanged", _localizablefieldsChangedHandler);
			_langsChanged = true;
			invalidateProperties();
			CommandController.addToQueue(new GetLocalizableCommand());
		}
		
		private function _langsChangedHandler(event:Event = null):void {
			_langsChanged = true;
			invalidateProperties();
		}
		
		private function _localizablefieldsChangedHandler(event:Event = null):void {
			_localizablefieldsChanged = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			var index:int = 1;
			var lang:String
			if(_langsChanged) {
				_langsChanged = false;
				index = 1;
				for each(lang in Model.instance.applicationVO.langs) {
					if(numChildren -1 < index)
						addChild(new LanguageBox());
					
					var lb:LanguageBox = getChildAt(index) as LanguageBox;
					lb.lang = lang;
					index++;
				}
				
				var pw:Number = 100 / numChildren;
				for(var i:int = numChildren -1; i >=0; i--) {
					UIComponent(getChildAt(i)).percentWidth = pw;
				}
			}
			
			if(_localizablefieldsChanged) {
				_localizablefieldsChanged = false;
				index = 1;
				lang = Model.instance.applicationVO.langs[0];
				for each(var field:Object in Model.instance.applicationVO.localizablefields[lang]) {
					if(names_vb.numChildren -1 < index)
						names_vb.addChild(new Label());
					
					var lbl:Label = names_vb.getChildAt(index) as Label;
					lbl.text = field.field + ":";
					lbl.height = 30;
					lbl.percentWidth = 100;
					lbl.setStyle('textAlign', 'right');
					index++;
				}
				
			}
		}
	}
}