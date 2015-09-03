package nl.bs10.bright.views {
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.containers.VBox;
	import mx.containers.ViewStack;
	import mx.controls.SWFLoader;
	import mx.events.ItemClickEvent;
	
	import nl.bs10.bright.commands.administrators.LogoutCommand;
	import nl.bs10.bright.commands.page.GetUpdatedPagesCommand;
	import nl.bs10.bright.commands.tree.UpdateTreeCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.views.files.FilesView;
	import nl.bs10.bright.views.modules.ModuleView;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.events.VeinDispatcher;

	public class MainView extends VBox {
		
		
		[Bindable]public var main_vs:ViewStack;
		[Bindable]public var moduleView:ModuleView;
		[Bindable]public var swfloader:SWFLoader;
		
		private var _appready:Boolean = false;
		
		public function MainView() {
			Model.instance.applicationVO.addEventListener('applicationStateChanged', _onApplicationStateChanged, false, 0, true);
		}
		
		public function setViewstack(event:ItemClickEvent):void {
			var index:int = 0;
			switch(event.item.name) {
				case 'structure':
					index = 0;
					CommandController.addToQueue(new GetUpdatedPagesCommand());
					CommandController.addToQueue(new UpdateTreeCommand());
					break;
				case 'templates':
					index = 1;
					break;
				case 'files':
					index = 2;
					VeinDispatcher.instance.dispatch('loadFileExplorer', null);
					break;
				case 'administrators':
					index = 3;
					break;
				case 'users':
					index = 4;
					break;
				case 'mailing':
					index = 5;
					break;
				case 'settings':
					index = 6;
					break;
				case 'calendars':
					index = 8;
					break;
				case 'elements':
					index = 9;
					break;
				case 'gmaps':
					index = 10;
					break;
				default:
					index = 11;
					moduleView.loadModule(event.item.name);
					
			}
			Model.instance.applicationVO.dispatchWindowChangeEvent(index);
		}
		
		override protected function commitProperties():void {
			if(_appready) {
				_appready = false;
				// @todo fix framerate issue
				/*swfloader.source = IconController.getGray('loaderanim');*/
			}
		}
		
		protected function logout():void {
			CommandController.addToQueue(new LogoutCommand());
		}

		protected function gotoSite():void {
			navigateToURL(new URLRequest(Model.instance.applicationVO.config.general.siteurl), "_blank");
		}

		protected function gotoHelp():void {
			navigateToURL(new URLRequest('help/manual.pdf'), "_blank");
		}
		
		protected function gotoAbout():void {
			Model.instance.applicationVO.dispatchWindowChangeEvent(7);
		}
		
		private function _onApplicationStateChanged(event:Event):void {
			if(Model.instance.applicationVO.applicationState == 1) {
				Model.instance.applicationVO.removeEventListener('applicationStateChanged', _onApplicationStateChanged);
				_appready = true;
				invalidateProperties();
			}
		}
	}
}