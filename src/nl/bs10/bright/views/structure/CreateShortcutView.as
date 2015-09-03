package nl.bs10.bright.views.structure {
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.views.renderers.CopyTreeItemRenderer;
	import nl.bs10.brightlib.objects.Page;
	import nl.bs10.brightlib.objects.TreeNode;
	
	public class CreateShortcutView extends Canvas {
		
		public var child_vb:VBox;
		
		public function CreateShortcutView() {
			super();
		}
		
		protected function close():void {
			PopUpManager.removePopUp(this);
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			if(!value)
				return;

			child_vb.removeAllChildren();
			var tir:CopyTreeItemRenderer = new CopyTreeItemRenderer();
			tir.data = value;
			tir.addEventListener(MouseEvent.MOUSE_DOWN, _startDrag, false, 0, true);
			child_vb.addChild(tir);
		}
		
		private function _startDrag(event:MouseEvent):void {
			
			var ds:DragSource = new DragSource();
		  	var tn:TreeNode = new TreeNode();
		  	tn.shortcut = event.currentTarget.data.shortcut;
		  	tn.locked = false;
		  	var p:Page = new Page();
		  	p.pageId = event.currentTarget.data.pageId;
		  	p.itemType = event.currentTarget.data.itemType;
		  	p.label = event.currentTarget.data.label;
		  	tn.page = p;
		  	ds.addData(tn, "FlpTreeData");
		  	
		  	var bmd:BitmapData = new BitmapData(event.currentTarget.width, event.currentTarget.height, true, 0x000);
		  	bmd.draw(event.currentTarget as IBitmapDrawable);
		  	
		  	var img:Image = new Image();
		  	img.source = bmd;
		  	img.x = mouseX;
		  	img.y = mouseY + 20;
			
		  	DragManager.doDrag(event.currentTarget as IUIComponent, ds, event, img);
		}
	}
}