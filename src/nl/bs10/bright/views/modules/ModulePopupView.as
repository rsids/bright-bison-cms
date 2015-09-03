package nl.bs10.bright.views.modules
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	/**
	 * With this class you can open any module in a popup from a plugin. This class adds a select and cancel button.
	 * To open a module from your plugin, dispatch a BrightEvent.DATAEVENT with a data object containing the following:
	 * <code>data = {type:"openModule", title:"TitleOfPopup" module:"nameOfTheModule", callback:yourCallbackFunction, params:{}}</code>
	 * The params property is optional and is passed to the module (so when used, make sure your module has a params property
	 * Your module needs to have a selected property which holds the selected value and is passed to the plugin by the callback function
	 * @author Ids Klijnsma - Fur
	 * 
	 */
	public class ModulePopupView extends TitleWindow
	{
		
		public var moduleView:ModuleView;
		public var cancelBtn:Button;
		public var selectBtn:Button;
		
		private var _module:String;
		private var _moduleChanged:Boolean;
		private var _callback:Function;
		private var _params:Object;
		private var _paramsChanged:Boolean;
		
		public function ModulePopupView() {
			super();
			layout = 'absolute';
			width = 800;
			height = 550;
			horizontalScrollPolicy = "off";
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, _cancelHandler);
		}
		
		public function set module(moduleName:String):void {
			_module = moduleName;
			_moduleChanged = true;
			invalidateProperties();
		}
		
		public function get module():String {
			return _module;
		}
		
		public function set params(value:Object):void {
			_params = value;
			_paramsChanged = true;
			invalidateProperties();
		}
		
		public function get params():Object {
			return _params;
		}
		
		public function set callback(value:Function):void {
			_callback = value;
		}
		
		public function get callback():Function {
			return _callback;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			moduleView = new ModuleView();
			moduleView.x = 0;
			moduleView.y = 30;
			
			cancelBtn = new Button();
			cancelBtn.label = 'Cancel';
			cancelBtn.addEventListener(MouseEvent.CLICK, _cancelHandler);
			cancelBtn.x = width - 180;
			
			selectBtn = new Button();
			selectBtn.label = 'Select';
			selectBtn.addEventListener(MouseEvent.CLICK, _selectHandler);
			selectBtn.x = width - 100;
			
			addChild(moduleView)
			addChild(cancelBtn);
			addChild(selectBtn);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_moduleChanged) {
				_moduleChanged = false;
				moduleView.loadModule(module);
			}
			if(_paramsChanged) {
				_paramsChanged = false;
				moduleView.setModuleParams(params);
			}
		}
		
		private function _cancelHandler(event:Event = null):void {
			moduleView.unload();
			PopUpManager.removePopUp(this);
		} 
		
		private function _selectHandler(event:MouseEvent):void {
			_callback(moduleView.plugin["child"].selected);
			_cancelHandler();
		}
	}
}