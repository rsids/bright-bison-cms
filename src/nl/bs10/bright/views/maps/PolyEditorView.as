package nl.bs10.bright.views.maps
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.controls.CheckBox;
	import mx.controls.ColorPicker;
	import mx.controls.ComboBox;
	import mx.controls.HSlider;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.views.content.ItemEditorView;
	import nl.bs10.bright.views.files.FilePopupView;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.bs10.brightlib.events.FileExplorerEvent;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.File;
	import nl.bs10.brightlib.objects.PolyPage;

	public class PolyEditorView extends ItemEditorView
	{
		
		[Bindable] public var layercolor_chb:CheckBox;
		[Bindable] public var color_cp:ColorPicker;
		[Bindable] public var layer_cmb:ComboBox;
		[Bindable] public var icon_img:Image;
		[Bindable] public var iconsize_hs:HSlider;
		[Bindable] public var enabled_chb:CheckBox;
		
		private var _polyChanged:Boolean;
		
		public function PolyEditorView() {
			super();
			Model.instance.polyVO.addEventListener("ItemChanged", _polyChangedHandler, false, 0, true);
		}
		
		override public function cancel(currentItem:IPage = null):void {
			MapsView(parentDocument).updatePoly(currentItem as PolyPage);
			super.cancel(currentItem);
		}
		
		override protected function save(callcancel:Boolean=true, error:Array=null):void {
			PolyPage(contentVO.currentItem).uselayercolor = layercolor_chb.selected;
			PolyPage(contentVO.currentItem).enabled = enabled_chb.selected;
			if(layer_cmb.selectedItem) {
				PolyPage(contentVO.currentItem).layer = layer_cmb.selectedItem.layerId;
			} else {
				error = new Array();
				error.push("Please select a layer for this poly");
			}
			if(PolyPage(contentVO.currentItem).uselayercolor) {
				PolyPage(contentVO.currentItem).color = layer_cmb.selectedItem.color;
			} else {
				PolyPage(contentVO.currentItem).color = color_cp.selectedColor;
			}
			
			
			super.save(callcancel, error);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_polyChanged) {
				_polyChanged = false;
				if(contentVO.currentItem) {
					for each(var layer:Object in Model.instance.markerVO.alayers) {
						if(layer.layerId == PolyPage(Model.instance.polyVO.currentItem).layer) {
							layer_cmb.selectedItem = layer;
							break;
						}
					}
				}
			}
		}
		
		private function _polyChangedHandler(event:Event):void {
			_polyChanged = true;
			invalidateProperties();
		}
	}
}