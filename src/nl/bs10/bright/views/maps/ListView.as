package nl.bs10.bright.views.maps {
	import com.adobe.utils.ArrayUtil;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import nl.bs10.bright.commands.maps.DeleteMarkerCommand;
	import nl.bs10.bright.commands.maps.GetMarkerCommand;
	import nl.bs10.bright.commands.maps.GetPolyCommand;
	import nl.bs10.bright.controllers.SettingsController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.controllers.DatagridController;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.objects.Layer;
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.bs10.brightlib.interfaces.IMarker;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.events.VeinDispatcher;
	import nl.fur.vein.events.VeinEvent;
	
	[Event(name="selectMarker", type="nl.fur.vein.events.VeinEvent")]
	public class ListView extends VBox {
		
		private var _columnsChanged:Boolean;
		private var _textFilter:String;
		
		private var _filter:Array;
		private var _filterChanged:Boolean;
		
		private var _items:ArrayCollection;
		private var _itemsChanged:Boolean;
		
		private var _mode:uint = 1;
		
		public static const NORMAL:uint = 0;
		public static const POPUP:uint = 1;
		
		[Bindable] public var list_dg:DataGrid;
		[Bindable] public var filter_txt:TextInput;
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_columnsChanged) {
				_columnsChanged = false;
				if(!Model.instance.administratorVO.getSetting('maps.visibleColumns')) {
					Model.instance.administratorVO.setSetting('maps.visibleColumns', Model.instance.applicationVO.config.columns.maps);
				}
				DatagridController.setDataGridColumns(list_dg, Model.instance.administratorVO.getSetting('maps.visibleColumns'));
				for each(var col:DataGridColumn in list_dg.columns) {
					
					switch(col.dataField) {
						case 'layer':
							col.labelFunction = _getLayerName;
							break;
					}
				}
			}
			
			if(_itemsChanged || _filterChanged) {
				
				if(items) {
					_itemsChanged = false;
					_filterChanged = false;
					if(filter) {
						items.filterFunction = _filterMarkers;
					} else {
						items.filterFunction = null;	
					}
					items.refresh();
				}
			}
			
		}
		
		protected function deleteItem():void {
			Alert.show("Are you sure you want to delete this marker?", "Please confirm", Alert.YES|Alert.NO, null,
				function(event:CloseEvent):void {
					if(event.detail == Alert.YES) {
						CommandController.addToQueue(new DeleteMarkerCommand(), list_dg.selectedItem.markerId, list_dg.selectedItem.pageId);
					}
				});
		}
		
		
		protected function editColumns():void {
			SettingsController.getEditColumnsPopup(Model.instance.applicationVO.config.columns.maps, Model.instance.templateVO.markerDefinitions,  'maps.visibleColumns');
		}
		
		protected function editItem(event:MouseEvent = null):void {
			if(!list_dg.selectedItem)
				return;
			
			if(list_dg.selectedItem is MarkerPage) {
				CommandController.addToQueue(new GetMarkerCommand(), list_dg.selectedItem.markerId);
			} else {
				CommandController.addToQueue(new GetPolyCommand(), list_dg.selectedItem.polyId);
			}
		}
		
		protected function filter_txt_keyUpHandler(event:KeyboardEvent):void {
			if(!items)
				return;
			
			if(event.keyCode == 13 && items.length == 1 && mode == POPUP) {
				// enter
				list_dg.selectedIndex = 0;
				onSelectMarker();
				items.filterFunction = null;
				items.refresh();
				return;
			}
			_textFilter = event.currentTarget.text != '' ? event.currentTarget.text : null;
			// Trigger filter
			if(items.filterFunction == _filterMarkers) {
				items.filterFunction = null;
				items.filterFunction = _filterMarkers;
			} else {
				items.filterFunction = null;
				items.filterFunction = _filterMarkersTextOnly;
				
			}
			items.refresh();
		}
		
		protected function listview_creationCompleteHandler(event:FlexEvent):void {
			Model.instance.administratorVO.addEventListener('settingsChanged', _onSettingsChange);
			_columnsChanged = true;
			invalidateProperties();
			listview_showHandler(event);
		}
		
		protected function listview_showHandler(event:FlexEvent):void {
			VeinDispatcher.instance.dispatch('requestMarkerUpdate', null);
			filter_txt.setFocus();
		}
		
		protected function newMarker():void {
			Model.instance.markerVO.currentItem = new MarkerPage();
		}
		
		protected function onSelectMarker():void {
			dispatchEvent(new VeinEvent('selectMarker',list_dg.selectedItem));
		}
		
		/**
		 * _filterMarkers function
		 *  
		 **/
		private function _filterMarkers(marker:IMarker):Boolean {
			if(ArrayUtil.arrayContainsValue(filter, marker.itemType.toString())) {
				return _filterMarkersTextOnly(marker);
			} else {
				return false;
			}
		}
		
		private function _filterMarkersTextOnly(marker:IMarker):Boolean {
			if(!marker.search || marker.search == null)
				return false;
			
			if(_textFilter) {
				return String(marker.search).toLowerCase().indexOf(_textFilter.toLowerCase()) != -1;
			}
			return true;
		}
		
		/**
		 * _getLayerName function
		 **/
		private function _getLayerName(data:Object, col:Object):String {
			for each(var layer:Layer in Model.instance.markerVO.layers) {
				if(layer.layerId ==	data.layer) {
					return layer.label;
				}
			}
			return '';
		} 
		
		/**
		 * _onSettingsChange function
		 **/
		private function _onSettingsChange(event:BrightEvent):void {
			if(event.data == 'maps.visibleColumns') {
				_columnsChanged = true;
				invalidateProperties();
			}
		}
		
		
		[Bindable(event="filterChanged")]
		public function set filter(value:Array):void {
			if(value !== _filter) {
				_filter = value;
				_filterChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("filterChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the filter property
		 **/
		public function get filter():Array {
			return _filter;
		}
		
		[Bindable(event="itemsChanged")]
		public function set items(value:ArrayCollection):void {
			var f:Function = (_items && _items.filterFunction != null) ? _items.filterFunction : null;
			if(value !== _items) {
				_items = value;
				_items.filterFunction = f;
				_items.refresh();
				_itemsChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("itemsChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the item property
		 **/
		public function get items():ArrayCollection {
			return _items;
		}
		
		[Bindable(event="modeChanged")]
		[Inspectable(enumeration=NORMAL,POPUP)]
		public function set mode(value:uint):void {
			if(value !== _mode) {
				_mode = value;
				dispatchEvent(new Event("modeChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the mode property
		 **/
		public function get mode():uint {
			return _mode;
		}
	}
}