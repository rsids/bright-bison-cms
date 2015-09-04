package nl.bs10.bright.views.renderers
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.ContextMenuEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.controls.Image;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.flexperiments.tree.FlpTree;
	import nl.flexperiments.tree.FlpTreeItemRenderer;
	import nl.flexperiments.tree.Node;

	[Bindable]
	public class TreeItemRenderer extends FlpTreeItemRenderer {
		private var _dataChanged:Boolean = false;
		
		private var _locked:Boolean;
		private var _loginrequired:Boolean;
		
		private var _shortcut_cmi:ContextMenuItem;
		private var _add_cmi:ContextMenuItem;
		private var _delete_cmi:ContextMenuItem;
		private var _edit_cmi:ContextMenuItem;
		private var _show_cmi:ContextMenuItem;
		private var _displayLabel:String;
		
		public var extraIcon:Image;
		
		public function TreeItemRenderer() {
			super();
			
			_shortcut_cmi = new ContextMenuItem("Create Shortcut to this page");
			_shortcut_cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _createShortcut, false, 0, true);
			
			_add_cmi = new ContextMenuItem("Add new page");
			_add_cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _addPage, false, 0, true);
			
			_delete_cmi = new ContextMenuItem("Remove Page");
			_delete_cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _deletePage, false, 0, true);
			
			_edit_cmi = new ContextMenuItem("Edit Page");
			_edit_cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _editPage, false, 0, true);
			
			_show_cmi = new ContextMenuItem("Show Page");
			_show_cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _showPage, false, 0, true);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			icon_img.height = 18;
			icon_img.setStyle("verticalAlign", "middle");
			icon_img.scaleContent = false;
			extraIcon = new Image();
			extraIcon.height = icon_img.height;
			extraIcon.width = icon_img.width;
			extraIcon.scaleContent = false;
			icon_img.includeInLayout = false;
			icon_img.parent.addChildAt(extraIcon, getChildIndex(icon_img) +1);
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			_dataChanged = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(data && _locked != data.locked)
				_dataChanged = true;	
			
			if(data && _loginrequired != data.loginrequired)
				_dataChanged = true;	
			
			if(!_dataChanged)
				return;
				
			_locked = data.locked;
			_loginrequired = data.loginrequired;
			_dataChanged = false;
			
			node.dragEnabled = !data.locked; 
			
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			
			toolTip = "Tree id: " + data.treeId;
			
			
			var customItems:Array = new Array();
			
			// No deletemenu on homepage
			if(!(node.parentNode is FlpTree))
				customItems.push(_delete_cmi);
			
			var d1:Date = new Date();
			d1.setTime(data.page.publicationdate * 10);	
			var d2:Date = new Date();
			d2.setTime(data.page.expirationdate * 10);
			var d3:Date = new Date();
			
			if(data.page) {
				if(data.page.alwayspublished || (d1.getTime() <= d3.getTime() && d2.getTime() >= d3.getTime())) {
					setStyle('color', 0x000000); 
					icon_img.alpha = 1;
				} else {
					setStyle('color', 0x666666); 
					icon_img.alpha = .6;
				}
				
				if(!data.page.showinnavigation) {
					setStyle('color', 0x5a6978); 
					icon_img.alpha = .6;
				}
			}
			
			if(data.shortcut == 0) {
				customItems.push(_shortcut_cmi);
				
			} else {
				label_txt.htmlText = "<i>Shortcut to " +  data.page.label + "</i>";
			}
				
			customItems.push(_edit_cmi);
			customItems.push(_add_cmi);
			customItems.push(_show_cmi);
			cm.customItems = customItems;
			
			contextMenu = cm;
			_checkIcon();
			invalidateDisplayList();
		}
		
		private function _checkIcon():void {
			extraIcon.source = null;
			var extra_bmd:BitmapData = new BitmapData(16, 16, true, 0x000000);
			
			if(data && (data.loginrequired || data.locked || data.shortcut > 0)) {
				// Create BMD
				
				if(data.locked) {
					extra_bmd.draw(new Model.instance.structureVO.lock_img());
				}
				if(data.shortcut > 0) {
					extra_bmd.draw(new Model.instance.structureVO.shortcut_img());
				}
				if(data.loginrequired) {
					extra_bmd.draw(new Model.instance.structureVO.login_img());
				}
			}
			
			extraIcon.source = new Bitmap(extra_bmd);
		}
		
		private function _deletePage(event:ContextMenuEvent):void {
			node.tree.dispatchEvent(new BrightEvent("DELETEPAGE", data));
		}
		
		private function _editPage(event:ContextMenuEvent):void {
			node.tree.dispatchEvent(new BrightEvent("EDITPAGE", data));
		}
		
		private function _createShortcut(event:ContextMenuEvent):void {
			node.tree.dispatchEvent(new BrightEvent("CREATESHORTCUT", data));
		}
		
		private function _addPage(event:ContextMenuEvent):void {
			node.tree.dispatchEvent(new BrightEvent("ADDPAGE", node));
		}
		
		private function _showPage(event:ContextMenuEvent):void {
			var path:String = (node.parentNode != null && node.parentNode.parentNode != null) ? data.page.label + "/" : "";
			var current:Node = node.parentNode;
			while(current != null) {
				if(current.parentNode && current.parentNode.parentNode)
					path = current.data.page.label + "/" + path;
					
				current = current.parentNode;
			}
			
			var url:URLRequest = new URLRequest();
			var prefix:String = Model.instance.applicationVO.config.general.useprefix ? Model.instance.pageVO.tabs.getItemAt(0).value + "/" : ''; 
			url.url = Model.instance.applicationVO.config.general.siteurl + prefix + path;
			navigateToURL(url, '_blank');
		}
	}
}