package nl.bs10.bright.views.maps
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.HDividedBox;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.maps.DeleteLayerCommand;
	import nl.bs10.bright.commands.maps.GetLayersCommand;
	import nl.bs10.bright.commands.maps.GetMarkerCommand;
	import nl.bs10.bright.commands.maps.GetPolyCommand;
	import nl.bs10.bright.commands.maps.SetLayerCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.utils.PluginManager;
	import nl.bs10.brightlib.components.GrayImageButton;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.Layer;
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.bs10.brightlib.objects.PolyPage;
	import nl.fur.vein.controllers.CommandController;

	public class MapsView extends HDividedBox
	{
		private var _mode:String = "edit";
		private var _mapsPlugin:UIComponent;
		
		[Bindable] public var layers_dg:DataGrid;
		[Bindable] public var list_dg:DataGrid;
		[Bindable] public var maps_cvs:Canvas;
		
		private var _displayMode:String;
		private var _displayModeChanged:Boolean;
		
		public var listBtn:GrayImageButton;
		public var mapBtn:GrayImageButton;
		
		public function loadMaps():void {
			CommandController.addToQueue(new GetLayersCommand());
			maps_cvs.removeAllChildren();	
			_mapsPlugin = PluginManager.getMaps();
			_mapsPlugin["child"].data = {"defaultzoom": 8};
			_mapsPlugin["child"].addEventListener(BrightEvent.DATAEVENT, _getObject);
			_mapsPlugin.percentWidth = 100;
			_mapsPlugin.percentHeight = 100;
			_mapsPlugin.x = 0;
			_mapsPlugin.y = 0;
			_mapsPlugin["styleName"] = "borderedBox";
			maps_cvs.addChild(_mapsPlugin); 

			if(Model.instance.administratorVO.administrator.settings && Model.instance.administratorVO.administrator.settings.hasOwnProperty('maps') && Model.instance.administratorVO.administrator.settings.maps.hasOwnProperty('defaultMode')) {
				displayMode = Model.instance.administratorVO.administrator.settings.maps.defaultMode;
			} else {
				displayMode = 'map';
			}
		}
		
		public function updateMarker(marker:MarkerPage):void {
			if(marker) {
				if(!Model.instance.markerVO.markers[marker.pageId]) {
					Model.instance.markerVO.markers[marker.pageId] = marker;
					Model.instance.markerVO.markersChanged = !Model.instance.markerVO.markersChanged;
					var arr:Array = [];
					arr = arr.concat(Model.instance.markerVO.markers, Model.instance.polyVO.polys);
					var arr2:Array = [];
					// Need to loop over to remove gaps, since arr is id based
					for each(var item:IPage in arr) {
						if(item)
							arr2.push(item);
					}
					Model.instance.mapsVO.items = new ArrayCollection(arr2);
				}
				_mapsPlugin["child"].updateMarker(marker);
			}
		}
		
		public function updatePoly(poly:PolyPage):void {
			/*if(poly)
				_mapsPlugin["child"].updatePoly(poly);*/
		}
		
		/**
		 * Add a listener to itemEditBeginning, and then add a listener to the
		 * changable properties. This way, changes are instant.
		 * Otherwise, you have to listen to itemEditEnd, which gets fired after a FocusOut, which is confusing for the user
		 */
		protected function checkField(event:DataGridEvent):void {
			if(!event.itemRenderer)
				return;
			
			switch(event.columnIndex) {
				case 0: // Checkbox
					Layer(event.itemRenderer.data).removeEventListener("visibleChanged", _setVisibilty );
					Layer(event.itemRenderer.data).addEventListener("visibleChanged", _setVisibilty, false, 0, true );
					break;
				case 2: // Color
					Layer(event.itemRenderer.data).addEventListener("colorChanged", _setColor, false, 0, true );
					break;
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_displayModeChanged) {
				_displayModeChanged = false;
				if(displayMode == 'list') {
					
				}
				
				
			}
		}
		
		protected function deleteLayer():void {
			Alert.show("Are you sure you want to delete this layer?", "Please confirm", Alert.YES|Alert.CANCEL, null, _deleteLayerHandler);
		}
		
		protected function setDisplayMode(value:String):void {
			displayMode = value;
		}
		
		/**
		 * Passes the selected layer to the maps plugin 
		 * @param setvisible When true, the layer is set to visible and the markers / polys are fetched
		 * 
		 */		
		protected function updateSelectedLayer(setvisible:Boolean = false):void {
			if(!layers_dg.selectedItem) {
				layers_dg.selectedIndex = 0;
			}
			_mapsPlugin["child"].selectedlayer = layers_dg.selectedItem;
			if(setvisible) {
				if(!layers_dg.selectedItem.visible) {
					layers_dg.selectedItem.visible = true;
					// Add markers
					_mapsPlugin["child"].getMarkers(layers_dg.selectedItem.layerId);
				}
			}
			
		}
		
		protected function layersChanged(event:DataGridEvent):void {
			var savelayer:Boolean = false;
			// Clean up listeners to prevent memory leaks
			Layer(event.itemRenderer.data).removeEventListener("visibleChanged", _setVisibilty);
			Layer(event.itemRenderer.data).removeEventListener("colorChanged", _setColor);
		}
		
		protected function openLayerEditor(event:Event = null):void {
			var popup:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject, LayerEditorViewLayout, true);
			LayerEditorViewLayout(popup).callback = _setLayerCallback;
			var layer:Layer = new Layer();
			layer.index = -1;
			if(event) {
				layer =  layers_dg.selectedItem as Layer;
			}
			
			LayerEditorViewLayout(popup).layer = layer;
			PopUpManager.centerPopUp(popup);
		}
		
		private function _deleteLayerCallback(layerId:int):void {
			_mapsPlugin["child"].removeMarkers(layerId);
		}
		
		private function _deleteLayerHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				CommandController.addToQueue(new DeleteLayerCommand(), layers_dg.selectedItem.layerId, _deleteLayerCallback);
			}
		}
		
		private function _getObject(event:BrightEvent):void {
			if(event.data is MarkerPage) {
				CommandController.addToQueue(new GetMarkerCommand(), event.data.markerId);
			} else if(event.data is PolyPage) {
				CommandController.addToQueue(new GetPolyCommand(), event.data.polyId);
				
			}
		}
		
		private function _setColor(event:Event):void {
			var layer:Layer = event.currentTarget as Layer;
			CommandController.addToQueue(new SetLayerCommand(), layer, false, _setLayerCallback);		
		}
		
		private function _setLayerCallback(updatedLayer:Layer):void {
			layers_dg.selectedItem = updatedLayer;
			// update colors?
			_mapsPlugin["child"].updateMarkers(updatedLayer.layerId, updatedLayer.color);
			_mapsPlugin["child"].updatePolyLines(updatedLayer.layerId, updatedLayer.color);
		}
		
		/**
		 * Sets the visibility of a layer 
		 * @param event
		 * 
		 */		
		private function _setVisibilty(event:Event):void {
			var layer:Layer = event.currentTarget as Layer;
			if(layer.visible) {
				trace('setvisible true');
				// Add markers
				_mapsPlugin["child"].getMarkers(layer.layerId);
			} else {
				trace('setvisible false');
				// Remove markers
				_mapsPlugin["child"].removeMarkers(layer.layerId);
			}
		}
		
		
		[Bindable(event="modeChanged")]
		public function set mode(val:String):void {
			if(val !== _mode) {
				_mode = val;
				dispatchEvent(new Event("modeChanged"));
			}
		}
		
		public function get mode():String {
			return _mode;
		}
		
		[Bindable(event="displayModeChanged")]
		public function set displayMode(value:String):void {
			if(value !== _displayMode) {
				_displayMode = value;
				_displayModeChanged = true;
				Model.instance.administratorVO.setSetting('maps.defaultMode', value);
				dispatchEvent(new Event("displayModeChanged"));
				invalidateProperties();
			}
		}
		
		/** 
		 * Getter/Setter methods for the displayMode property
		 **/
		public function get displayMode():String {
			return _displayMode;
		}
	}
}