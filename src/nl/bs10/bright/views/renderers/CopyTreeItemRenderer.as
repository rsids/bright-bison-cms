package nl.bs10.bright.views.renderers
{
	import flash.ui.ContextMenu;
	
	import mx.containers.HBox;
	import mx.controls.Image;
	import mx.controls.Text;
	import mx.events.FlexEvent;
	
	import nl.bs10.brightlib.controllers.IconController;

	[Bindable]
	public class CopyTreeItemRenderer extends HBox {
		
		protected var label_txt:Text = new Text();
		protected var icon_img:Image = new Image();
		
		public function CopyTreeItemRenderer() {
			super();
			icon_img.height = 18;
			icon_img.setStyle("verticalAlign", "middle");
			icon_img.scaleContent = false;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
				
			icon_img.mouseChildren = false;
			icon_img.mouseEnabled = true;
			
			label_txt.selectable = false;
			label_txt.mouseChildren = false;
			label_txt.percentWidth = 100;
			label_txt.styleName = "shortcutText";
			
			addChild(icon_img);
			addChild(label_txt);
			
		}
		
	    [Bindable("dataChange")]
	    [Inspectable(environment="none")]
		override public function set data(value:Object):void {
			super.data = value;
			if(!value) { 
				dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
				return;
			}
			
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			
			contextMenu = cm;
			icon_img.source = IconController.getIcon(value);
			label_txt.text = "Shortcut to " + value.label;
		}
		
		
	}
}