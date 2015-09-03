package nl.bs10.bright.views.templates {
	
	import com.adobe.utils.ArrayUtil;
	import com.adobe.utils.StringUtil;
	
	import flash.desktop.Clipboard;
	import flash.events.Event;
	
	import mx.containers.HDividedBox;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	import mx.events.DataGridEventReason;
	
	import nl.bs10.bright.commands.cache.FlushCacheCommand;
	import nl.bs10.bright.commands.template.DeleteTemplateCommand;
	import nl.bs10.bright.commands.template.SetLifetimeCommand;
	import nl.bs10.bright.commands.template.SetMaxChildrenCommand;
	import nl.bs10.bright.commands.template.SetTemplateCommand;
	import nl.bs10.bright.components.BrightDataGrid;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.components.Prompt;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.objects.Template;
	import nl.fur.vein.controllers.CommandController;

	public class TemplateView extends HDividedBox {
		
		[Bindable] public var templates_dg:BrightDataGrid;
		[Bindable] public var templateView:TemplateEditViewLayout;
		
		private var _pastedTemplate:Template;
		private var _pasteInto:Template;
		
		protected function saveChanges(event:DataGridEvent):void {
			if(event.reason == DataGridEventReason.CANCELLED)
				return;
			if(event.dataField == "maxchildren") {
				var newmax:Number = DataGrid(event.currentTarget).itemEditorInstance["value"];
				newmax = Math.max(newmax, -1);
				CommandController.addToQueue(new SetMaxChildrenCommand(), event.itemRenderer.data.id, newmax);
				
			} else if(event.dataField == "lifetime") {
				// Validate data
				var newlifetime:String = StringUtil.trim(DataGrid(event.currentTarget).itemEditorInstance["text"]);
				var oldlifetime:String = event.itemRenderer.data.lifetime;
				var isValid:Boolean = true;
				// Invalid
				if(newlifetime == "") {
					DataGrid(event.currentTarget).itemEditorInstance["text"] = oldlifetime;
					isValid = false;
				}
				
				var arr:Array = newlifetime.split(" ");
				
				if(isValid && arr.length == 2) {
					arr[1] = String(arr[1]).toLowerCase();
					
				} else {
					isValid = false;
				}
				
				// Invalid
				if(isValid && isNaN(Number(arr[0]))) {
					DataGrid(event.currentTarget).itemEditorInstance["text"] = oldlifetime;
					isValid = false;	
				}
				
				var timespan:Array = ["minutes", "hours", "days", "weeks", "months", "years"];
				var pls:String = arr[1] + "s";
				if(isValid && (ArrayUtil.arrayContainsValue(timespan, arr[1]) || ArrayUtil.arrayContainsValue(timespan, pls))) {
					// Valid!
					isValid = true;
					newlifetime = arr[0] +" " + arr[1];
				} else {
					isValid = false;
				}
				
				if(isValid) {
					CommandController.addToQueue(new SetLifetimeCommand(), event.itemRenderer.data.id, newlifetime);
				} else {
					DataGrid(event.currentTarget).itemEditorInstance["text"] = oldlifetime;
				}
			}
		}
		
		protected function editDefinition():void {
			Model.instance.templateVO.selectedTemplate = Template(templates_dg.selectedItem).clone();
		}
		
		protected function newTemplate():void {
			Model.instance.templateVO.selectedTemplate = new Template();
		}
		
		protected function deleteTemplate():void {
			if(!templates_dg.selectedItem)
				return;
			Alert.show('Are you sure you want to delete this template?\n(this action cannot be undone)',
				'Please confirm...',
				Alert.YES|Alert.CANCEL, null, _deleteHandler);
		}
		
		protected function _deleteHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES)
				CommandController.addToQueue(new DeleteTemplateCommand(), templates_dg.selectedItem.id);
		}
		
		protected function flushCache():void {
			CommandController.addToQueue(new FlushCacheCommand());
		}
		
		protected function getTemplatetype(data:Template, column:Object):String {
			for each(var type:Object in Model.instance.templateVO.types) {
				if(type.type == data.templatetype)
					return type.label;
			}
			return 'Invalid type'
		}
		
		protected function copyTemplate():void {
			if(!templates_dg.selectedItem)
				return;
			
			Clipboard.generalClipboard.setData("Template", templates_dg.selectedItem as Template);
		}
		
		protected function pasteTemplate(event:Event):void {
			_pastedTemplate = Clipboard.generalClipboard.getData("Template") as Template;
			if(!_pastedTemplate)
				return;
			
			_pastedTemplate.id = 0;
			var found:Boolean = false;
			for each(var template:Template in Model.instance.templateVO.templateDefinitions) {
				if(template.itemtype == _pastedTemplate.itemtype) {
					_pasteInto = template.clone();
					Alert.yesLabel = 'Overwrite';
					Alert.noLabel = 'Rename';
					Alert.show("A template with that label already exists,\n do you want to overwrite or rename the template?","Template already exists", Alert.YES|Alert.NO|Alert.CANCEL, null, _pasteHandler);
					found = true;
				}
			}
			if(!found) {
				CommandController.addToQueue(new SetTemplateCommand(), _pastedTemplate);
			}
		}
		
		private function _pasteHandler(event:CloseEvent):void {
			switch(event.detail) {
				case Alert.YES:
					_pasteInto.merge(_pastedTemplate);
					CommandController.addToQueue(new SetTemplateCommand(), _pasteInto, false);
					break;
				case Alert.NO:
					Prompt.show("Enter the new label of the template", 
						"Enter label", 
						function(event:BrightEvent):void {
							_pastedTemplate.itemtype = event.data.toString();
							CommandController.addToQueue(new SetTemplateCommand(), _pastedTemplate, false);
						}, 'a-z0-9');
					break;
			}
			
			Alert.yesLabel = 'Yes';
			Alert.noLabel = 'No';
		}
		
	}
}