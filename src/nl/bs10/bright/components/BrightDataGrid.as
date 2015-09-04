package nl.bs10.bright.components
{
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.setTimeout;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.DataGridEvent;
	import mx.events.FlexEvent;
	import mx.events.ScrollEvent;
	import mx.utils.ObjectUtil;
	
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.controllers.CommandController;

	[Event(name="deleteItem", type="flash.events.Event")]
	[Event(name="editItem", type="flash.events.Event")]
	public class BrightDataGrid extends DataGrid
	{
		
		private var _scrollpos:int;
		private var _oldWidth:Number;
		
		private var _settingsname:String;
		private var _settingsnameChanged:Boolean;
		private var _columnsChanged:Boolean;
		private var _widthChanged:Boolean;
		
		public function BrightDataGrid()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, _setContext, false, 0, true);
			addEventListener(DataGridEvent.HEADER_RELEASE, _resetScroll, false, 0, true);
			addEventListener(ScrollEvent.SCROLL, _saveScroll, false, 0, true);
			addEventListener(DataGridEvent.COLUMN_STRETCH, _onColumnStretch, false, 0, true);
			addEventListener(KeyboardEvent.KEY_UP, _onKeyUp, false, 0, true);
		}
		
		public function restoreScroll():void {
			verticalScrollPosition = _scrollpos;
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_settingsnameChanged || _columnsChanged || _widthChanged) {
				if(!settingsname || !columns || width == 0) 
					return;
				
				var colWidths:Array = Model.instance.administratorVO.getSetting(settingsname +'.colwidths.w'+ width);
				if(colWidths && colWidths.length == columns.length) {
					setTimeout(function():void {
						_columnsChanged = false;
						_settingsnameChanged = false;
						_widthChanged = false;
						var i:int = 0;
						for(i = 0; i < colWidths.length; i++) {
							columns[i].width = 0;
						}
						for(i = 0; i < colWidths.length; i++) {
							columns[i].width = colWidths[i];
						}}, 100);
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(unscaledWidth != _oldWidth) {
				_oldWidth = unscaledWidth;
				_widthChanged = true;
				invalidateProperties();
			}
		}
		
		/**
		 * _onColumnStretch function
		 *  
		 **/
		private function _onColumnStretch(event:DataGridEvent):void {
			if(!settingsname)
				return;
			
			var colWidths:Array = [];
			for(var i:int = 0; i < columns.length; i++) {
				colWidths.push(columns[i].width);
			}
			Model.instance.administratorVO.setSetting(settingsname +'.colwidths.w'+ width, colWidths);
		}
		
		/**
		 * _onKeyUp function
		 *  
		 **/
		private function _onKeyUp(event:KeyboardEvent):void {
			if(!selectedItem)
				return;
			
			switch(event.keyCode) {
				case 13:
					// Enter
					dispatchEvent(new Event('editItem'));
					break;
				case 46:
					dispatchEvent(new Event('deleteItem'));
					break;
			}
		}
		private function _setContext(event:FlexEvent):void {
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			
			var customItems:Array = new Array();
			
			var colors:Array = ['black', 'blue', 'green', 'pink', 'purple', 'red', 'yellow', 'remove label'];
			
			var cmi:ContextMenuItem = new ContextMenuItem("Add label:", false, false);
			customItems.push(cmi);
			var sep:Boolean = true;
			for each(var color:String in colors) {
				cmi = new ContextMenuItem(color, sep);
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _selectColor, false, 0, true);
				customItems.push(cmi);
				sep = false;
			}
			
			cm.customItems = customItems;
			contextMenu = cm;
		}
		
		private function _selectColor(event:ContextMenuEvent):void {
			var vsp:int = this.verticalScrollPosition;
			var color:String = (ContextMenuItem(event.currentTarget).caption == 'remove label') ? null : ContextMenuItem(event.currentTarget).caption;
			var labels:Object = Model.instance.administratorVO.getSetting(settingsname +'.labels') ;
			if(!labels)
				labels = {};
			
			if(selectedItems.length > 0) {
				for each(var data:* in selectedItems) {
					if(color == null) {
						delete labels[data[settingsname + 'Id']];
					} else {
						labels[data[settingsname + 'Id']] = color;
					}
					data.coloredlabel = (color != null) ? "bullet_" + color : null;
				}
			} else {
				// Nothing selected, highlight object under point.
				event.mouseTarget['data'].coloredlabel = (color != null) ? "bullet_" + color : null;
				if(color == null) {
					delete labels[event.mouseTarget['data'][settingsname + 'Id']];
				} else {
					
					labels[event.mouseTarget['data'][settingsname + 'Id']] = color;
				}
			}
			Model.instance.administratorVO.setSetting(settingsname +'.labels', labels, Model.instance.administratorVO.administrator.labelsChanged);
		}
		
		private function _saveScroll(event:ScrollEvent):void {
			_scrollpos = verticalScrollPosition;
		}
		
		private function _resetScroll(event:DataGridEvent):void {
			event.preventDefault();
            sortByColumn(event.columnIndex);
			var c:DataGridColumn = columns[event.columnIndex];
			Model.instance.administratorVO.setSetting(settingsname +'.defaultsort', columns[event.columnIndex].dataField);
			Model.instance.administratorVO.setSetting(settingsname +'.defaultsortdir', columns[event.columnIndex].sortDescending ? 'DESC':'ASC');
            restoreScroll();
		}
		
		/**
		 * Since the original function is private we cannot override it :(
		 */
		private function sortByColumn(index:int):void {
			var c:DataGridColumn = columns[index];
			var desc:Boolean = c.sortDescending;
			
			// do the sort if we're allowed to
			if (c.sortable){
				var s:Sort = collection.sort;
				var f:SortField;
				if (s){
					s.compareFunction = null;
					// analyze the current sort to see what we've been given
					var sf:Array = s.fields;
					if (sf){
						for (var i:int = 0; i < sf.length; i++){
						
							if (sf[i].name == c.dataField){
								// we're part of the current sort
								f = sf[i];
								// flip the logic so desc is new desired order
								desc = !f.descending;
								break;
							}
						}
					}
				} else {
					s = new Sort;
				}
			
				if (!f)
					f = new SortField(c.dataField);
			
			
				c.sortDescending = desc;
				
				
				// if you have a labelFunction you must supply a sortCompareFunction
				f.name = c.dataField;
				if (c.sortCompareFunction != null){
					f.compareFunction = c.sortCompareFunction;
				}else{
					f.compareFunction = null;
				}
				f.descending = desc;
				s.fields = [f];
			}
				
			collection.sort = s;
			collection.refresh();
		
		}
		
		[Bindable(event="settingsnameChanged")]
		public function set settingsname(value:String):void {
			if(value !== _settingsname) {
				_settingsname = value;
				_settingsnameChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("settingsnameChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the settingsname property
		 **/
		public function get settingsname():String {
			return _settingsname;
		}
		
		override public function set columns(value:Array):void {
			super.columns = value;
			if(value) {
				_columnsChanged = true;
				invalidateProperties();
			}
		}
		
	}
}