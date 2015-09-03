package nl.bs10.bright.views.users
{
	import flash.events.Event;
	
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.users.DeleteUserGroupCommand;
	import nl.bs10.bright.commands.users.SetUserGroupCommand;
	import nl.bs10.brightlib.components.Prompt;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.fur.vein.controllers.CommandController;

	public class UserGroupsView extends TitleWindow
	{
		
		private var _group:Object;
		
		public function UserGroupsView()
		{
			super();
		}
		
		protected function addGroup():void {
			Prompt.show("Please enter the name of the group", "Enter groupname", _addGroupHandler); 
		}
		
		protected function deleteGroup(group:Object):void {
			_group = group;
			Alert.show("Are you sure you want to delete this usergroup?\n(Users in this group will NOT be deleted)","Please confirm", Alert.YES| Alert.NO, null, _deleteGroupHandler);
		}
	
		protected function close():void {
			PopUpManager.removePopUp(this);
		}
		
		private function _deleteGroupHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				//_group
				CommandController.addToQueue(new DeleteUserGroupCommand(), _group.groupId);
			}
		}
		
		private function _addGroupHandler(event:BrightEvent):void {
			CommandController.addToQueue(new SetUserGroupCommand(), {groupname:event.data.toString()});
		}
	}
}