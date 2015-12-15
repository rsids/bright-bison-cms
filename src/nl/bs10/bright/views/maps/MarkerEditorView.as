package nl.bs10.bright.views.maps
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.controls.CheckBox;
	import mx.controls.ColorPicker;
	import mx.controls.ComboBox;
	import mx.controls.HSlider;
	import mx.controls.Image;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.maps.GeocodeCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.utils.Log;
	import nl.bs10.bright.views.content.ItemEditorView;
	import nl.bs10.bright.views.files.FilePopupView;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.bs10.brightlib.events.FileExplorerEvent;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.File;
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.fur.vein.controllers.CommandController;

	public class MarkerEditorView extends ItemEditorView
	{
		
		[Bindable] public var layercolor_chb:CheckBox;
		[Bindable] public var color_cp:ColorPicker;
		[Bindable] public var layer_cmb:ComboBox;
		[Bindable] public var icon_img:Image;
		[Bindable] public var enabled_chb:CheckBox;
		[Bindable] public var iconsize_hs:HSlider;
		
		[Bindable] public var street_txt:TextInput;
		[Bindable] public var number_txt:TextInput;
		[Bindable] public var zip_txt:TextInput;
		[Bindable] public var city_txt:TextInput;
		[Bindable] public var country_txt:TextInput;
		
		private var _markerChanged:Boolean;
		
		public function MarkerEditorView() {
			super();
			Model.instance.markerVO.addEventListener("ItemChanged", _markerChangedHandler, false, 0, true);
		}
		
		override public function cancel(currentItem:IPage = null):void {
			MapsView(parentDocument).updateMarker(currentItem as MarkerPage);
			super.cancel(currentItem);
		}
		
		protected function browseIcon():void {
			var event:FileExplorerEvent = new FileExplorerEvent(FileExplorerEvent.OPENFILEEXPLOREREVENT, _setIcon, false, ['jpg','png','gif']);
			var p:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject,
																FilePopupView,
																true);
			FilePopupView(p).setProperties(event);
			PopUpManager.centerPopUp(p);
		}
		
		protected function lookupAddress():void {
			CommandController.addToQueue(new GeocodeCommand(), GeocodeCommand.FROMLATLNG, contentVO.currentItem);
		}
		
		protected function lookupPosition():void {
			var marker:MarkerPage = contentVO.currentItem as MarkerPage;
			marker.street = street_txt.text;
			marker.zip = zip_txt.text;
			marker.city = city_txt.text;
			marker.country = country_txt.text;
			marker.number = number_txt.text;
			CommandController.addToQueue(new GeocodeCommand(), GeocodeCommand.FROMADDRESS, contentVO.currentItem);
		}
		
		protected function resetIcon():void {
			MarkerPage(contentVO.currentItem).icon = '';
			icon_img.source = IconController.getGray('noimage');
		}
		
		override protected function save(callcancel:Boolean=true, error:Array=null):void {
			MarkerPage(contentVO.currentItem).uselayercolor = layercolor_chb.selected;
			MarkerPage(contentVO.currentItem).street = street_txt.text;
			MarkerPage(contentVO.currentItem).zip = zip_txt.text;
			MarkerPage(contentVO.currentItem).city = city_txt.text;
			MarkerPage(contentVO.currentItem).country = country_txt.text;
			MarkerPage(contentVO.currentItem).number = number_txt.text;
			if(layer_cmb.selectedItem) {
				MarkerPage(contentVO.currentItem).layer = layer_cmb.selectedItem.layerId;
			} else {
				error = new Array();
				error.push("Please select a layer for this marker");
			}
			if(MarkerPage(contentVO.currentItem).uselayercolor) {
				MarkerPage(contentVO.currentItem).color = layer_cmb.selectedItem.color;
			} else {
				MarkerPage(contentVO.currentItem).color = color_cp.selectedColor;
			}
			
			MarkerPage(contentVO.currentItem).enabled = enabled_chb.selected;
			MarkerPage(contentVO.currentItem).iconsize = iconsize_hs.value;
			
			Log.add("Marker is about to save");
			super.save(callcancel, error);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_markerChanged) {
				_markerChanged = false;
				if(contentVO.currentItem) {
					for each(var layer:Object in Model.instance.markerVO.alayers) {
						if(layer.layerId == MarkerPage(Model.instance.markerVO.currentItem).layer) {
							layer_cmb.selectedItem = layer;
							break;
						}
					}
					if(Model.instance.markerVO.currentMarker.icon && Model.instance.markerVO.currentMarker.icon != "") {
						icon_img.source = Model.instance.applicationVO.config.filesettings.fileurl + Model.instance.markerVO.currentMarker.icon;
					} else {
						icon_img.source = IconController.getGray('noimage');
					}
				}
			}
		}
		
		private function _markerChangedHandler(event:Event):void {
			_markerChanged = true;
			invalidateProperties();
		}
		
		private function _setIcon(value:File):void {
			Model.instance.markerVO.currentMarker.icon = value.path + value.filename;
			icon_img.source = Model.instance.applicationVO.config.filesettings.fileurl + Model.instance.markerVO.currentMarker.icon;
		}
	}
}