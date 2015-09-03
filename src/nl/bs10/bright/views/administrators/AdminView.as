package nl.bs10.bright.views.administrators
{
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.events.CloseEvent;
	
	import nl.bs10.bright.commands.administrators.DeleteAdminCommand;
	import nl.bs10.bright.commands.administrators.GetAdministratorsCommand;
	import nl.bs10.bright.controllers.PermissionController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Administrator;
	import nl.fur.vein.controllers.CommandController;

	public class AdminView extends Canvas {
		
		[Bindable] public var users_dg:DataGrid;
		[Bindable] protected var isEditing:Boolean = false;
		
		protected function showHandler():void {
			CommandController.addToQueue(new GetAdministratorsCommand());
		}
		
		protected function addAdministrator():void {
			Model.instance.administratorVO.editAdministrator = new Administrator();
			isEditing = true;
		}
		
		protected function editAdministrator():void {
			if(PermissionController.instance._MANAGE_ADMIN) {
				Model.instance.administratorVO.editAdministrator = users_dg.selectedItem as Administrator;
			} else if((users_dg.selectedItem as Administrator).id == Model.instance.administratorVO.administrator.id) {
				Model.instance.administratorVO.editAdministrator = users_dg.selectedItem as Administrator;
			} else {
				return;
			}
			isEditing = true;
		}
		
		protected function deleteAdministrator():void {
			if(!users_dg.selectedItem)
				return;
						
			Alert.show("Are you sure you want to delete this user?", "Please confirm", Alert.YES|Alert.NO, this, _deleteHandler);
		}
		
		
		
		private function _deleteHandler(event:CloseEvent):void {
			if(event.detail == Alert.NO)
				return;
				
			CommandController.addToQueue(new DeleteAdminCommand(), users_dg.selectedItem as Administrator);
		}
	}
}