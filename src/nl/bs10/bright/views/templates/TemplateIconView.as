package nl.bs10.bright.views.templates
{
	import flash.display.Loader;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.TitleWindow;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.controllers.IconController;

	public class TemplateIconView extends TitleWindow
	{
		public var opener:TemplateEditView;
		
		public function TemplateIconView()
		{
			super();
			title = "Choose Icon";
			width = 640;
			height = 450;
			showCloseButton = true;
			addEventListener(CloseEvent.CLOSE, _close, false, 0, true);
			horizontalScrollPolicy = "off";
			verticalScrollPolicy = "off";
			layout = "vertical";
		}
		
		override protected function createChildren():void {
			super.createChildren();
			var ldr:Loader = IconController.icons.loader;
			var uic:UIComponent = new UIComponent();
			uic.addChild(ldr.content);
			uic.width = width;
			uic.height = height;
			uic.useHandCursor = true;
			uic.setStyle("backgroundColor", "0xffffff");
			addChild(uic);
			uic.addEventListener(MouseEvent.CLICK, _upEvent, false, 0, true);
		}
		
		private function _upEvent(event:MouseEvent):void {
			Model.instance.templateVO.selectedTemplate.icon = getQualifiedClassName(event.target);
			opener.iconChanged();
			opener = null;
			_close();
		}
		
		private function _close(event:CloseEvent = null):void {
			PopUpManager.removePopUp(this);
		}
		
	}
}