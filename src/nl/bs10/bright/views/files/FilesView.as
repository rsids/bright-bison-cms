package nl.bs10.bright.views.files
{
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.core.UIComponent;
	
	import nl.bs10.bright.controllers.PermissionController;
	import nl.bs10.bright.utils.PluginManager;
	import nl.fur.vein.events.VeinDispatcher;
	import nl.fur.vein.events.VeinEvent;

	public class FilesView extends Canvas  {
		
		
		public var ca:VBox = new VBox();
		
		public function FilesView() {
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren()
			percentHeight =
			percentWidth = 100;
			
			ca.setStyle("left", 0);
			ca.setStyle("right", 0);
			ca.setStyle("top", 10);
			ca.setStyle("bottom", 0);
			ca.setStyle("paddingLeft", 10);
			ca.setStyle("paddingRight", 10);
			ca.setStyle("paddingTop", 10);
			ca.setStyle("paddingBottom", 10);
			ca.styleName = "borderedBox";
			
			addChild(ca);
			VeinDispatcher.instance.addEventListener('loadFileExplorer', _loadExplorer);
		}
		
		private function _loadExplorer(event:VeinEvent):void {
			ca.removeAllChildren();	
			var dpo:UIComponent = PluginManager.getExplorer();
			//dpo["styleName"] = "borderedBox";
			dpo["child"].setProperties(null, false, true, null, PermissionController.instance._UPLOAD_FILE, PermissionController.instance._DELETE_FILE);
			dpo.percentWidth = 100;
			dpo.percentHeight = 100;
			ca.addChild(dpo);
		}
	}
}