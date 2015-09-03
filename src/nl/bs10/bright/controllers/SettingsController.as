package nl.bs10.bright.controllers {
	import com.adobe.utils.ArrayUtil;
	
	import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import mx.containers.DividedBox;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.events.DividerEvent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Template;
	import nl.bs10.bright.views.settings.DataGridSettingsViewLayout;

	public class SettingsController {
		
		public static function setDividerWidth(event:DividerEvent, divider:String):void {
			var div:DividedBox = event.currentTarget as DividedBox;
			
			Model.instance.administratorVO.setSetting(divider + "." + divider + "width" + div.stage.stageWidth, div.getChildAt(0).width + event.delta);
			
		}
		
		public static function getDividerWidth(divider:String):Number {
			return Number(Model.instance.administratorVO.getSetting(divider + "." + divider + "width" + Application.application.stage.stageWidth));
		}
		
		/**
		 * _setLabels function
		 *  
		 **/
		public static function setLabels(arr:Array, prop:String):void {
			var labels:Object = Model.instance.administratorVO.getSetting(prop + '.labels');
			for(var label:String in labels) {
				if(arr[label]) {
					arr[label].coloredlabel = "bullet_" + labels[label];
				}
			}
			
		}
		
		public static function getEditColumnsPopup(availableColumns:Array, definitions:ArrayCollection, visibleColumns:String):void {
			var popup:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject, DataGridSettingsViewLayout, true);
			var arr:Array = ArrayUtil.copyArray(availableColumns);
			var fields:Object = {};
			
			for each(var template:Template in definitions) {
				for each(var field:Object in template.fields) {
					fields[field.label] = field.label;
				}
			}
			for(var prop:String in fields) {
				arr.push(fields[prop]);
			}
			DataGridSettingsViewLayout(popup).visibleColumns = visibleColumns;
			DataGridSettingsViewLayout(popup).availableColumns = arr;
			PopUpManager.centerPopUp(popup);
		}
	}
}