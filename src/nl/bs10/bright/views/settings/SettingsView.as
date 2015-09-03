package nl.bs10.bright.views.settings {
	import flash.display.DisplayObject;
	
	import mx.containers.VBox;
	import mx.controls.CheckBox;
	
	import nl.bs10.bright.commands.administrators.ResetSettingsCommand;
	import nl.bs10.bright.commands.config.GetSettingsCommand;
	import nl.bs10.bright.commands.config.SetSettingsCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.views.renderers.SettingsRenderer;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.events.VeinDispatcher;
	import nl.fur.vein.events.VeinEvent;

	public class SettingsView extends VBox  {
		
		private var _doRefresh:Boolean = false;
		
		public var settings_vb:VBox;
		public var columns_vb:VBox;
		
		override protected function createChildren():void {
			super.createChildren();
			VeinDispatcher.instance.addEventListener('settingsChanged', _onSettingsChange);
		} 
		
		protected function getSettings():void {
		//	CommandController.addToQueue(new GetBrightSettingsCommand());
			CommandController.addToQueue(new GetSettingsCommand());
		}
		
		protected function resetSettings():void {
			CommandController.addToQueue(new ResetSettingsCommand());
		}
		
		protected function save():void {
			var ca:Array = settings_vb.getChildren();
			var so:Array = new Array();
			for each(var sr:SettingsRenderer in ca) {
				so.push(sr.data);
			}
			
			/*ca = columns_vb.getChildren();
			
			var co:Array = new Array();
			for each(var child:DisplayObject in ca) {
				if(child is CheckBox) {
					if(child['selected']) 
						co.push(Number(child['data']));
				}
			} */
			
			CommandController.addToQueue(new SetSettingsCommand(), so);
		}
		
		protected function newSetting():void {
			var sr:SettingsRenderer = new SettingsRenderer();
			sr.isnew = true;
			settings_vb.addChild(sr);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_doRefresh && settings_vb) {
				_doRefresh = false;
				while(settings_vb.numChildren != 0)
					settings_vb.removeChildAt(0);
					
				for each(var setting:Object in Model.instance.settingsVO.custom) {
					var sr:SettingsRenderer = new SettingsRenderer();
					sr.data = setting;
					sr.isnew = false;
					settings_vb.addChild(sr);
				}
			}
		}
		
		public function refresh():void {
			_doRefresh = true;
			invalidateProperties();
		}
		
		/**
		 * _onSettingsChange function
		 *  
		 **/
		private function _onSettingsChange(event:VeinEvent):void {
			refresh();
		}
	}
}