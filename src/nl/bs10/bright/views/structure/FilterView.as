package nl.bs10.bright.views.structure {
	
	import flash.events.Event;
	
	import mx.containers.VBox;
	import mx.controls.CheckBox;
	import mx.controls.HRule;
	import mx.events.FlexMouseEvent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Template;

	public class FilterView extends VBox {
		
	
		public function FilterView() {
			super();
			width = 300;
			setStyle("paddingLeft", 10);
			setStyle("paddingRight", 10);
			setStyle("paddingTop", 10);
			setStyle("paddingBottom", 10);
			maxHeight = 275
			horizontalScrollPolicy = "off";
			addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, _removeView, false, 0, true);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			var chb:CheckBox = new CheckBox();
			chb.label = 'Invert selection';
			chb.selected = true;
			chb.addEventListener(Event.CHANGE, _invertHandler, false, 0, true);
			addChild(chb);
			var hr:HRule = new HRule();
			hr.percentWidth = 100;
			addChild(hr);
			
			for each(var template:Template in Model.instance.templateVO.templateDefinitions) {
				chb = new CheckBox();
				chb.data = template.id;
				chb.label = template.templatename;
				chb.selected = true;
				chb.addEventListener(Event.CHANGE, _chbChangeHandler, false, 0, true);
				addChild(chb);
			};
		}
		
		private function _chbChangeHandler(event:Event):void {
			Model.instance.pageVO.filterTemplateIds[event.currentTarget.data] = event.currentTarget.selected;
			Model.instance.pageVO.apages.refresh();
		}
		
		private function _invertHandler(event:Event):void {
			var nc:int = numChildren;
			for(var i:int = 2; i < numChildren; i++) {
				var chb:CheckBox = getChildAt(i) as CheckBox;
				chb.selected = !chb.selected;
				Model.instance.pageVO.filterTemplateIds[chb.data] = chb.selected;
			}
			Model.instance.pageVO.apages.refresh();
		}
		
		private function _removeView(event:FlexMouseEvent):void {
			PopUpManager.removePopUp(this);
		}
		
		
	}
}