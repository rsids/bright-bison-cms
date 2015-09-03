package nl.bs10.bright.views.structure {
	
	import com.adobe.utils.ArrayUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.Application;
	import mx.core.ClassFactory;
	import mx.core.DragSource;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.page.DeletePageCommand;
	import nl.bs10.bright.commands.page.GetPageCommand;
	import nl.bs10.bright.commands.page.SearchPagesCommand;
	import nl.bs10.bright.commands.page.SetPageCommand;
	import nl.bs10.bright.components.BrightDataGrid;
	import nl.bs10.bright.controllers.PermissionController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.views.settings.DataGridSettingsViewLayout;
	import nl.bs10.brightlib.components.renderers.DGCheckboxRenderer;
	import nl.bs10.brightlib.components.renderers.IconRenderer;
	import nl.bs10.brightlib.controllers.DatagridController;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.objects.Page;
	import nl.bs10.brightlib.objects.TreeNode;
	import nl.bs10.brightlib.objects.Template;
	import nl.bs10.brightlib.utils.Formatter;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.events.VeinDispatcher;
	import nl.fur.vein.events.VeinEvent;

	public class ListView extends VBox
	{
		private var _sto:uint;
		
		[Bindable] public var structure_dg:BrightDataGrid;
		[Bindable] public var search_txt:TextInput;
		[Bindable] public var delete_btn:Button;
		
		private var _draggedItem:TreeNode;
		private var _columnsChanged:Boolean;
		
				
		public function createItem():void {
			Model.instance.pageVO.currentItem = new Page();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_columnsChanged) {
				_columnsChanged = false;
				if(!Model.instance.administratorVO.getSetting('page.visibleColumns')) {
					Model.instance.administratorVO.setSetting('page.visibleColumns', Model.instance.applicationVO.config.columns.page);
				}
				DatagridController.setDataGridColumns(structure_dg, Model.instance.administratorVO.getSetting('page.visibleColumns'));
				
			}
		}
		
		protected function deletePage():void {
			Alert.show("Are you sure you want to delete this page / these pages?\n(This action cannot be undone)",
				"Please confirm",
				Alert.YES|Alert.CANCEL,
				this,
				_deletePageHandler);
		}
		
		protected function editItem():void {
			if(!PermissionController.instance._EDIT_PAGE) 
				return; 
			
			CommandController.addToQueue(new GetPageCommand(), structure_dg.selectedItem.pageId, _toEditor);
		}
		
		
		protected function editColumns():void {
			var popup:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject, DataGridSettingsViewLayout, true);
			var arr:Array = ArrayUtil.copyArray(Model.instance.applicationVO.config.columns.page);
			var fields:Object = {};
			
			for each(var template:Template in Model.instance.templateVO.templateDefinitions) {
				for each(var field:Object in template.fields) {
					fields[field.label] = field.label;
				}
			}
			for(var prop:String in fields) {
				arr.push(fields[prop]);
			}
			DataGridSettingsViewLayout(popup).visibleColumns = 'page.visibleColumns';
			DataGridSettingsViewLayout(popup).availableColumns = arr;
			PopUpManager.centerPopUp(popup);
		}
		
		protected function listview1_creationCompleteHandler(event:FlexEvent):void {
			VeinDispatcher.instance.addEventListener('updatePageListScrollPosition', _onUpdatePageListScrollPosition);
			Model.instance.administratorVO.addEventListener('settingsChanged', _onSettingsChange);
			_columnsChanged = true;
			invalidateProperties();
		}
		
		protected function showFilters(event:MouseEvent):void {
			var b:Button = event.currentTarget as Button;
			if(!Model.instance.pageVO.filterView) {
				Model.instance.pageVO.filterView = PopUpManager.createPopUp(Application.application as DisplayObject, FilterView, false);
			} else {
				PopUpManager.addPopUp(Model.instance.pageVO.filterView, Application.application as DisplayObject, false);
			}
			var r:Rectangle = b.getRect(b);
			var p:Point = localToGlobal(new Point(r.width + b.x + r.x, r.height + b.y + r.y));
			Model.instance.pageVO.filterView.x = p.x - Model.instance.pageVO.filterView.width;
			Model.instance.pageVO.filterView.y = p.y;
			PopUpManager.bringToFront(Model.instance.pageVO.filterView);
		}
		
		protected function sortByType(a:Object, b:Object):int {
			return (a.itemType > b.itemType) ? 1 : -1;
		}
		
		protected function startDragNode(event:DragEvent):void {
		  	var ds:DragSource = new DragSource();
		  	
		  	
		  	var label:Text = new Text();
		  	label.width = 150;//.height = event.currentTarget.selectedItems.length * 20;
		  	label.styleName = "dragText";
		  	label.setStyle("backgroundColor", 0xffffff);
		  	
		  	var darray:Array = new Array();
		  	
		  	for each(var selectedItem:Page in event.currentTarget.selectedItems) {
		  		label.text += selectedItem.label + "\r\n";
		  		var tn:TreeNode = new TreeNode();
		 	 	tn.page = selectedItem;	
		 	 	darray.push(tn);
		  	}
		  	ds.addData(darray, "FlpTreeData");
		  	
		  	label.x = DataGrid(event.currentTarget).mouseX;
		  	label.y = DataGrid(event.currentTarget).mouseY + 20;

		  	DragManager.doDrag(event.dragInitiator, ds, event, label);

		}
		
		protected function textChangeHandler(event:Event):void {
			clearTimeout(_sto);
			_sto = setTimeout(_filterText, 100);
		}

		protected function updateItem(event:DataGridEvent):void {
			var page:Page = event.itemRenderer.data as Page;
			this.callLater(_realUpdate, [page.pageId]);
			structure_dg.removeEventListener(DataGridEvent.ITEM_EDIT_END, updateItem);
		}
		
		private function _deletePageHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				// Fire Command
				CommandController.addToQueue(new DeletePageCommand(), structure_dg.selectedItems);				
			}
		}
		
		private function _filterText():void {
			if(search_txt.text == "") {
				Model.instance.pageVO.filterPageIds = null;
				Model.instance.pageVO.apages.refresh();
				return;
			} 
			
			CommandController.addToQueue(new SearchPagesCommand(), search_txt.text);
			
		}
		
		/**
		 * _onSettingsChange function
		 *  
		 **/
		private function _onSettingsChange(event:BrightEvent):void {
			if(event.data == 'page.visibleColumns') {
				_columnsChanged = true;
				invalidateProperties();
			}
		}
		
		/**
		 * _onPageAdded function
		 *  
		 **/
		private function _onUpdatePageListScrollPosition(event:VeinEvent):void {
			structure_dg.restoreScroll();
		}
		
		private function _toEditor(co:Page):void {
			Model.instance.pageVO.currentItem = co.clone();
		}
		
		private function _realUpdate(id:Number):void {
			CommandController.addToQueue(new SetPageCommand(), Model.instance.pageVO.pages[id]);
		}
	
	}
}