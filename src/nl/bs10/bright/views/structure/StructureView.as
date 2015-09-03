package nl.bs10.bright.views.structure {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.page.GetPageCommand;
	import nl.bs10.bright.commands.tree.AddPageCommand;
	import nl.bs10.bright.commands.tree.AddPagesCommand;
	import nl.bs10.bright.commands.tree.CreateShortcutCommand;
	import nl.bs10.bright.commands.tree.DeletePageFromTreeCommand;
	import nl.bs10.bright.commands.tree.GetChildrenCommand;
	import nl.bs10.bright.commands.tree.MovePageCommand;
	import nl.bs10.bright.commands.tree.MovePagesCommand;
	import nl.bs10.bright.commands.tree.SetLockedCommand;
	import nl.bs10.bright.components.BrightDividedBox;
	import nl.bs10.bright.controllers.PermissionController;
	import nl.bs10.bright.controllers.SettingsController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.objects.Page;
	import nl.bs10.brightlib.objects.TreeNode;
	import nl.flexperiments.events.FlpTreeEvent;
	import nl.flexperiments.tree.FlpTree;
	import nl.flexperiments.tree.Node;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.events.VeinDispatcher;
	import nl.fur.vein.events.VeinEvent;

	public class StructureView extends Canvas {
		
		[Bindable] public var structure_vs:ViewStack;
		[Bindable] public var structure_tree:FlpTree;
		[Bindable] public var divider:BrightDividedBox;
		
		private var _deleteIds:Array;
		private var _deleteData:TreeNode;
		
		private var _shortcutView:IFlexDisplayObject;
		
		public function StructureView() {
			addEventListener(FlexEvent.CREATION_COMPLETE, _addListeners, false, 0, true);
		}
		
		/**
		 * Adds a new page to the tree 
		 * @param parent The parent Node
		 */		
		protected function addNewPageToTree(parent:Node):void {
			if(!parent)
				return;
			
			Model.instance.structureVO.currentItem = new TreeNode();
			// THIS IS WRONG, IT SHOULD BE PARENTID!!!!!!
			Model.instance.structureVO.currentItem.treeId = parent.data.treeId;
			Model.instance.structureVO.currentItem.index = parent.data.numChildren;
			
			Model.instance.pageVO.currentItem = new Page();
			Model.instance.structureVO.currentItem.page = Model.instance.pageVO.currentItem as Page;
		}
		
		
		protected function structureview1_creationCompleteHandler(event:FlexEvent):void
		{
			var w:Number = SettingsController.getDividerWidth('page');
			if(!isNaN(w) && w > 0) {
				divider.getChildAt(0).width = w;
			}
		}
		
		public function createShortcut(event:BrightEvent):void {
			if(!_shortcutView) {
				_shortcutView = PopUpManager.createPopUp(this, CreateShortcutViewLayout, false);
			} else {
				
				try{
					PopUpManager.removePopUp(_shortcutView);
				} catch(ex:Error){/*Swallow it*/}
				
				PopUpManager.addPopUp(_shortcutView, this, false);
			}
			CreateShortcutViewLayout(_shortcutView).data = {itemType: event.data.page.itemType, shortcut:event.data.treeId, pageId: event.data.page.pageId, label:event.data.page.label};
			var pos:Point = localToGlobal(new Point(structure_tree.x + structure_tree.width, structure_tree.y))
			_shortcutView.x = pos.x + 10;
			_shortcutView.y = pos.y;
			PopUpManager.bringToFront(_shortcutView);
		}
		
		public function deletePage(event:BrightEvent):void {
			
			if(event.data is Array) {
				var arr:Array = new Array();
				for each(var tn:Node in event.data) {
					arr.push(tn.data);
				}
				_deleteIds = arr;
				
				Alert.show("Are you sure you want to delete these pages from the navigation?", 
					"Please confirm", 
					Alert.YES|Alert.CANCEL, 
					null, 
					_bulkDeleteHandler);
				return;
			}
			
			_deleteData = event.data as TreeNode;
			
			if(_deleteData.locked) {
				Alert.show("You cannot delete locked pages", 
					"Cannot delete"); 
				return;
			}
			
			Alert.show("Are you sure you want to delete this page from the navigation?", 
				"Please confirm", 
				Alert.YES|Alert.CANCEL, 
				null, 
				_deleteHandler);
		}
		
		public function selectedNodeChangeEvent(event:FlpTreeEvent):void {
			if(event.data is Node) return;
			Model.instance.structureVO.selectedNode = event.data as TreeNode;
			structureOpenEvent(event);
		}
		
		public function structureOpenEvent(event:FlpTreeEvent):void {
			if(event.data.children && event.data.children.length > 0) 
				return;
			
			if(event.data.numChildren > 0) {
				event.data.children = new ArrayCollection();
				CommandController.addToQueue(new GetChildrenCommand(), event.data);
			}
		}
		
		
		protected function deletePageByButton():void {
			var ev:BrightEvent;
			if(!structure_tree.selectedNode)
				return;
			
			if(structure_tree.selectedNodes.length > 1) {
				ev = new BrightEvent("", structure_tree.selectedNodes);
				
			} else {
				ev = new BrightEvent("", structure_tree.selectedNode.data);
				
			}
			deletePage(ev);
		}
		
		protected function editTreeItem(event:Event = null):void {
			if(!PermissionController.instance._EDIT_PAGE)
				return;
			
			if(!event && !structure_tree.selectedNode)
				return;
			
			var pid:Number = (event) ? event["data"].page.pageId : structure_tree.selectedNode.data.page.pageId;
			CommandController.addToQueue(new GetPageCommand(), pid, _toEditor);
			
		}
		
		protected function pageDropped(event:FlpTreeEvent):void {
			
			var index:int;
			
			if(event.data.newparent.shortcut > 0) {
				ArrayCollection(event.data.oldparent.children).addItemAt(event.data.newparent.children.removeItemAt(event.data.newindex), event.data.oldindex);
				event.data.newparent.children = null;
				Alert.show("A shortcut cannot have children", "Cannot add / move");
				return;
			}
			
			if(event.data.oldindex == -1) {
				// New item added
				if(event.data.item is Array) {
					CommandController.addToQueue(new AddPagesCommand(), event.data.item, event.data.newparent, event.data.newindex);
					event.data.newparent.children.removeItemAt(event.data.newindex);
				} else {
					if(event.data.item.shortcut > 0) {
						//Add Shortcut
						CommandController.addToQueue(new CreateShortcutCommand(), event.data);
					} else {
						CommandController.addToQueue(new AddPageCommand(), event.data.item, event.data.newparent, event.data.newindex);
					}
				}
				
			} else {
				// Moved item
				var items:Array; 
				var multiple:Boolean = false;
				if(event.data.item is Array) {
					items = event.data.item;
					multiple = true;
				} else {
					items = [event.data.item];
				}
				var i:int = 0;
				var validitems:Array = new Array();
				var errors:Array = [];
				for each(var ditem:Node in items) {
					if((ditem && ditem.data && ditem.data.locked) || event.data.newparent.label == "ROOT" || !PermissionController.instance._MOVE_PAGE) {
						index = event.data.newparent.children.getItemIndex(ditem.data);
						
						var item:TreeNode = event.data.newparent.children.removeItemAt(index) as TreeNode;
						if(event.data.oldparent) {
							// When some fail and some don't, the index might get screwed up
							var oi:uint = Math.min(event.data.oldparent.children.length, event.data.oldindices[i]);
							event.data.oldparent.children.addItemAt(item, oi);
						}
						
						if(ditem && ditem.data && ditem.data.locked) {
							errors.push('Cannot move ' + ditem.data.page.label + ' because it\'s locked');
						}
						
						if(!multiple)
							return;
					} else {
						validitems.push({treeId:ditem.data.treeId, oldparentId:ditem.data.parentId, oldindex: event.data.oldindices[i], newindex: event.data.newindices[i], newparentId:event.data.newparent.treeId});
					}
					i++;
				}

				if(errors.length > 0) {
					Alert.show('Some pages could not be moved:' + String.fromCharCode(13) + '- ' + errors.join(String.fromCharCode(13) + '- '), 'Cannot move page(s)');
				}

				if(multiple) {
					CommandController.addToQueue(new MovePagesCommand(), validitems, event.data.newparent, event.data.newindex);
					
				} else {
					CommandController.addToQueue(new MovePageCommand(), event.data);
				}
				
			}
		}
		
		protected function refresh():void {
			Model.instance.structureVO.structure.removeAll();
			Model.instance.structureVO.structure = new ArrayCollection();
			Model.instance.structureVO.treeItems = new Array();
			
			CommandController.addToQueue(new GetChildrenCommand(), null);
		}
		
		
		protected function setLocked(node:Node):void {
			if(!node)
				return;
				
			CommandController.addToQueue(new SetLockedCommand(), node.data.treeId, !node.data.locked);
		}
		
		protected function setLogin(node:Node):void {
			
			if(!node)
				return;
				
			var ugpopup:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject, ChooseUserGroupViewLayout, true);
			ChooseUserGroupView(ugpopup).treeId = node.data.treeId;
			PopUpManager.centerPopUp(ugpopup);
		}
		
		private function _addListeners(event:FlexEvent):void {
			structure_tree.addEventListener("CREATESHORTCUT", createShortcut, false, 0, true);
			structure_tree.addEventListener("DELETEPAGE", deletePage, false, 0, true);
			structure_tree.addEventListener("EDITPAGE", editTreeItem, false, 0, true);
			structure_tree.addEventListener("ADDPAGE", _addNewPageToTreeHandler, false, 0, true);
			Model.instance.pageVO.addEventListener('ItemChanged', _onItemChange);
			VeinDispatcher.instance.addEventListener('shortcutCreated', _onShortcutCreated);
			VeinDispatcher.instance.addEventListener('childrenOfRootNodeFetched', _onChildrenOfRootNodeFetched);
		}
		
		private function _addNewPageToTreeHandler(event:BrightEvent):void {
			addNewPageToTree(event.data as Node);
		}
		
		private function _bulkDeleteHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				CommandController.addToQueue(new DeletePageFromTreeCommand(), _deleteIds, true);
			}
			_deleteIds = null;
		}
		
		private function _deleteHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				CommandController.addToQueue(new DeletePageFromTreeCommand(), _deleteData);
			}
			_deleteData = null;
		}
			
		private function _onChildrenOfRootNodeFetched(event:VeinEvent):void {
			var node:Node = structure_tree.findNodes("data.treeId", event.data)[0];
			node.open = true;
		}
		
		/**
		 * _onItemChange function
		 *  
		 **/
		private function _onItemChange(event:Event):void {
			structure_vs.selectedIndex = (Model.instance.pageVO.currentItem !== null) ? 1 : 0;
			if(structure_vs.selectedIndex == 1) {
				
			}
		}
		
		/**
		 * _onShortcutCreated function
		 *  
		 **/
		private function _onShortcutCreated(event:VeinEvent):void {
			PopUpManager.removePopUp(_shortcutView);
		}
		
		private function _toEditor(co:Page):void {
			Model.instance.pageVO.currentItem = co.clone();
		}
	}
}