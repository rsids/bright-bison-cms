package nl.bs10.bright.views.maps
{
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.ColorPicker;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.maps.SetLayerCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.components.LabeledInput;
	import nl.bs10.brightlib.objects.Layer;
	import nl.fur.vein.controllers.CommandController;

	public class LayerEditorView extends TitleWindow
	{
		[Bindable] public var lang_vb:VBox;
		[Bindable] public var color_cp:ColorPicker;
		
		public var callback:Function;
		
		private var _layer:Layer;
		private var _layerChanged:Boolean;
		
		public function LayerEditorView()
		{
			super();
		}
		
		public function set layer(value:Layer):void {
			if(value !== _layer) {
				_layer = value;
				_layerChanged = true;
				invalidateProperties();
			}
		}
		
		public function get layer():Layer {
			return _layer;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			for each(var tab:Object in Model.instance.markerVO.tabs) {
				if(tab.value != "settings") {
					var li:LabeledInput = new LabeledInput();
					li.label = tab.label;
					li.data = tab.value;
					lang_vb.addChild(li);
				}
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_layerChanged) {
				if(layer) { 
					if(layer.content && layer.content.hasOwnProperty("title")) {
					
						for each(var li:LabeledInput in lang_vb.getChildren()) {
							if(layer.content.title.hasOwnProperty(li.data.toString())) {
								li.text = layer.content.title[li.data.toString()];
							}
						}
					}
					
					color_cp.selectedColor = uint(layer.color);
				}
			}
		}
		
		protected function close():void {
			PopUpManager.removePopUp(this);
		}
		
		protected function save():void {
			var titleObject:Object = {};
			var hasTitle:Boolean = false;
			for each(var li:LabeledInput in lang_vb.getChildren()) {
				if(li.text != "") {
					titleObject[li.data.toString()] = li.text;
					hasTitle = true;
				}
			}
			if(hasTitle) {
				if(!_layer.hasOwnProperty('content') || _layer.content == null)
					_layer.content = {};
					
				_layer.content.title = titleObject;
				_layer.color = color_cp.selectedColor;
				CommandController.addToQueue(new SetLayerCommand(), layer, false, callback);
				layer = null;
				callback = null;
				close();
			} else {
				Alert.show("Please enter the name of the layer for at least 1 language", "Enter name");
			}
		}
		
	}
}