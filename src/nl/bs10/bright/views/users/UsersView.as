package nl.bs10.bright.views.users
{
	import com.adobe.utils.ArrayUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HDividedBox;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.controls.DataGrid;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.PopUpManager;
	import mx.utils.Base64Encoder;
	
	import nl.bs10.bright.commands.users.DeleteUserCommand;
	import nl.bs10.bright.commands.users.GetCSVCommand;
	import nl.bs10.bright.commands.users.GetUserCommand;
	import nl.bs10.bright.commands.users.GetUserGroupsCommand;
	import nl.bs10.bright.commands.users.GetUsersCommand;
	import nl.bs10.bright.commands.users.UploadCSVCommand;
	import nl.bs10.bright.controllers.SettingsController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.objects.User;
	import nl.bs10.brightlib.controllers.DatagridController;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.fur.vein.controllers.CommandController;

	public class UsersView extends HDividedBox {
		
		
		[Bindable] public var users_dg:DataGrid;
		[Bindable] public var dg_vbox:VBox;
		[Bindable] public var userView:UserEditorView;
		
		private var _csv:String;
		private var _fr:FileReference;
		private var _columnsChanged:Boolean;
		private var _userChanged:Boolean;
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_columnsChanged) {
				_columnsChanged = false;
				if(!Model.instance.administratorVO.getSetting('user.visibleColumns')) {
					Model.instance.administratorVO.setSetting('user.visibleColumns', Model.instance.applicationVO.config.columns.user);
				}
				DatagridController.setDataGridColumns(users_dg, Model.instance.administratorVO.getSetting('user.visibleColumns'));
				
			}
			
			if(_userChanged) {
				_userChanged = false;
				if(Model.instance.userVO.currentUser) {
					dg_vbox.percentWidth = 25;
					userView.percentWidth = 75;
				} else {
					dg_vbox.percentWidth = 100;
					userView.percentWidth = 0;
					
				}
			}
			
			
		}
		
		
		protected function addUser():void {
			Model.instance.userVO.currentItem = new User();
			//	Model.instance.userVO.currentUser.permissions.push("IS_CLIENT_AUTH");
		}
		
		protected function deleteUser():void {
			if(!users_dg.selectedItem)
				return;
			
			Alert.show("Are you sure you want to delete this user?", "Please confirm", Alert.YES|Alert.NO, this, _deleteHandler);
		}
		
		protected function downloadCSV():void {
			CommandController.addToQueue(new GetCSVCommand());
		}
		
		
		protected function editColumns():void {
			SettingsController.getEditColumnsPopup(Model.instance.applicationVO.config.columns.user, Model.instance.templateVO.userDefinitions,  'user.visibleColumns');
		}
		
		protected function editUser():void {
			if(users_dg.selectedItem)
				CommandController.addToQueue(new GetUserCommand(), users_dg.selectedItem.userId);
		}
		
		protected function getUsergroupsForDisplay(user:User, col:Object):String {
			return user.usergroups.join(',');
		}
		
		protected function openGroupEditor():void {
			PopUpManager.centerPopUp(PopUpManager.createPopUp(Application.application as DisplayObject, UserGroupsViewLayout, true));
		}
		
		protected function showHandler():void {
			CommandController.addToQueue(new GetUserGroupsCommand());
			CommandController.addToQueue(new GetUsersCommand());
			Model.instance.userVO.addEventListener("currentUserChanged", _userChangedHandler, false, 0, true);
		}
		
		protected function usersview1_creationCompleteHandler(event:FlexEvent):void {
			Model.instance.administratorVO.addEventListener('settingsChanged', _onSettingsChange);
			_columnsChanged = true;
			invalidateProperties();
		}
		
		protected function uploadCSV():void {
			if(_fr) {
				_fr.removeEventListener(Event.SELECT, _selectHandler);
				_fr.removeEventListener(Event.COMPLETE, _csvLoadHandler);
			}
			_fr = new FileReference();
			_fr.addEventListener(Event.SELECT, _selectHandler);
			_fr.browse([new FileFilter('Comma Separated File (*.csv)', '*.csv')]);
		}
		
		
		private function _csvLoadHandler(event:Event):void {
			var enc:Base64Encoder = new Base64Encoder();
			enc.encodeBytes(_fr.data);
			_csv = enc.toString();
			var w:Number = Alert.buttonWidth;
			Alert.yesLabel = "Skip";
			Alert.noLabel = "Overwrite";
			Alert.cancelLabel = "Fill empty fields";
			Alert.buttonWidth = 150;
			
			Alert.show("How should duplicate e-mails be treated?", "Please Choose", Alert.YES|Alert.NO|Alert.CANCEL, null, _uploadHandler);
			
			Alert.yesLabel = "Yes";
			Alert.noLabel = "No";
			Alert.cancelLabel = "Cancel";
			Alert.buttonWidth = w;
		}
		
		private function _deleteHandler(event:CloseEvent):void {
			if(event.detail == Alert.NO)
				return;
			
			CommandController.addToQueue(new DeleteUserCommand(), users_dg.selectedItem as User);
		}
		
		/**
		 * _onSettingsChange function
		 *  
		 **/
		private function _onSettingsChange(event:BrightEvent):void {
			if(event.data == 'user.visibleColumns') {
				_columnsChanged = true;
				invalidateProperties();
			}
		}
		
		private function _selectHandler(event:Event):void {
			_fr.addEventListener(Event.COMPLETE, _csvLoadHandler);
			_fr.load();
		}
		
		private function _uploadHandler(event:CloseEvent):void {
			var mode:String = 'skip';
			switch(event.detail) {
				case Alert.NO:
					mode = 'overwrite';
					break;
				case Alert.CANCEL:
					mode = 'fillempty';
					break;
			}
			CommandController.addToQueue(new UploadCSVCommand(), _csv, mode);
		}
		
		private function _userChangedHandler(event:Event):void {
			_userChanged = true;
			invalidateProperties();
			
		}
		
	}
}