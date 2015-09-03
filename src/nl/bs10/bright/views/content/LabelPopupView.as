package nl.bs10.bright.views.content {
	
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.TextInput;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.page.GenerateLabelCommand;
	import nl.bs10.bright.commands.page.SetPageCommand;
	import nl.bs10.bright.model.objects.CalendarEvent;
	import nl.bs10.brightlib.interfaces.IContentVO;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;

	public class LabelPopupView extends Panel {
		
		[Bindable] public var label_txt:TextInput = new TextInput();
		
		public var callback:Function;
		
		public var contentVO:IContentVO;
		
		public var command:ICommand;
		
		protected function save():void {
			var error:Array = new Array();
			if(label_txt.text == "") {
				error.push("The field 'label' is required");
			}
			var p:IPage = contentVO.currentItem.clone();
			p.pageId = 0;
			if(p is CalendarEvent) {
				p['calendarId'] = 0;
			}
			if(error.length == 0) {
				// Execute command
				contentVO.currentItem = p;
				contentVO.save(close);
			} else {
				Alert.show(error.join("\n"), "Cannot save page");
			}
		}
		
		protected function updateLabel():void {
			contentVO.currentItem.label = label_txt.text;
			CommandController.addToQueue(new GenerateLabelCommand(), contentVO);
		}		
		
		protected function cancel():void {
			label_txt.text = "";
			PopUpManager.removePopUp(this);
		}
		
		protected function close():void {
			cancel();
			contentVO = null;
			if(callback != null)
				callback();
			
		}
	}
}