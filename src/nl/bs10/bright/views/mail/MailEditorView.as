package nl.bs10.bright.views.mail {
	
	import flash.events.MouseEvent;
	
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.List;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;
	
	import nl.bs10.bright.commands.mailing.SendMailCommand;
	import nl.bs10.bright.commands.mailing.SendTestMailCommand;
	import nl.bs10.bright.commands.mailing.ShowPreviewCommand;
	import nl.bs10.bright.commands.users.GetUserGroupsCommand;
	import nl.bs10.bright.views.content.ItemEditorView;
	import nl.bs10.brightlib.interfaces.IPlugin;
	import nl.fur.vein.controllers.CommandController;

	public class MailEditorView extends ItemEditorView {
		
		[Bindable] public var testmail_txt:TextInput;
		[Bindable] public var usergroup_vb:VBox;
		[Bindable] public var send_btn:Button;
		
		public function MailEditorView()
		{
			super();
		}
		
		override protected function save(callcancel:Boolean=true, error:Array = null):void {
			var langvs:VBox = item_vs.getChildAt(0) as VBox;
			var ip:IPlugin = langvs.getChildAt(0) as IPlugin;
			label_txt.text = ip.value.toString();
			updateLabel();
			super.save(callcancel);
		}
		
		protected function showHandler():void {
			CommandController.addToQueue(new GetUserGroupsCommand());
		}
		
		protected function preview():void {
			save(false);
			CommandController.addToQueue(new ShowPreviewCommand());
		}
		
		protected function send(event:MouseEvent):void {
			var btn:Button = event.currentTarget as Button;
			btn.enabled = false;
			var selectedGroups:Array = [];
			var nc:uint = usergroup_vb.numChildren;
			while(--nc > -1) {
				if(CheckBox(usergroup_vb.getChildAt(nc)).selected) {
					selectedGroups.push(CheckBox(usergroup_vb.getChildAt(nc)).data);
				}
			}
			if(selectedGroups.length == 0) {
				Alert.show("You have to select at least one usergroup to send the mail to", "Cannot send mail");
				event.currentTarget.enabled = true;
				return;
			}
			
			Alert.show("Are you sure?", "Please Confirm", Alert.YES|Alert.CANCEL, null, function(event:CloseEvent):void {
				if(event.detail == Alert.YES) {
					save(false);
					CommandController.addToQueue(new SendMailCommand(), selectedGroups, _enableSend);
					
				} else {
					btn.enabled = true;
					
				}
			});
		}
		
		protected function sendTest():void {
			// Save first to make sure we have a pageId
			save(false);
			CommandController.addToQueue(new SendTestMailCommand(), testmail_txt.text);
		}
		
		private function _enableSend():void {
			send_btn.enabled = true;
		}
		
	}
}