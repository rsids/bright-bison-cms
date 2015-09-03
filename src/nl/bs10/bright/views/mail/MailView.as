package nl.bs10.bright.views.mail {
	
	import flash.events.Event;
	
	import mx.containers.HDividedBox;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.events.CloseEvent;
	
	import nl.bs10.bright.commands.mailing.DeleteMailingCommand;
	import nl.bs10.bright.commands.mailing.GetMailingCommand;
	import nl.bs10.bright.commands.page.GetPagesCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.vo.TemplateVO;
	import nl.bs10.brightlib.objects.Page;
	import nl.bs10.brightlib.objects.Template;
	import nl.fur.vein.controllers.CommandController;

	public class MailView extends HDividedBox  {
		
		[Bindable] public var dg_vbox:VBox;
		[Bindable] public var mails_dg:DataGrid;
		[Bindable] public var mailEditorView:MailEditorViewLayout;
		
		protected function showHandler():void {
			CommandController.addToQueue(new GetPagesCommand(), TemplateVO.MAILINGTEMPLATE);
			for each(var template:Template in Model.instance.templateVO.rawTemplateDefinitions) {
				if(template.templatetype == TemplateVO.MAILINGTEMPLATE) {
					Model.instance.mailingVO.template = template;
					break;
				}
			}
			if(!Model.instance.mailingVO.template)
				Alert.show("No mailing template found", "Create a mail template");
			Model.instance.mailingVO.addEventListener("ItemChanged", _mailChangedHandler, false, 0, true)
		}
		
		protected function addMail():void {
			Model.instance.mailingVO.currentItem = new Page();
		}
		
		protected function editMail():void {
			CommandController.addToQueue(new GetMailingCommand(), (mails_dg.selectedItem as Page).pageId);
		}
		
		protected function deleteMail():void {
			Alert.show("Are you sure you want to delete this mailing?", 
						"Please Confirm",
						Alert.YES|Alert.NO, 
						null, 
						function(event:CloseEvent):void {
							if(event.detail == Alert.YES){
								CommandController.addToQueue(new DeleteMailingCommand(), (mails_dg.selectedItem as Page).pageId);
							}
						});
		}
		
		private function _mailChangedHandler(event:Event):void {
			if(Model.instance.mailingVO.currentItem) {
				dg_vbox.percentWidth = 25;
				mailEditorView.percentWidth = 75;
			} else {
				dg_vbox.percentWidth = 100;
				mailEditorView.percentWidth = 0;
			}
			
		}
		
		protected function sortByType(a:Object, b:Object):int {
			return (a.itemType > b.itemType) ? 1 : -1;
		}
	}
}