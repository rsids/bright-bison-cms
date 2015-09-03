package nl.bs10.bright.views.administrators {
	
	import com.adobe.crypto.SHA1;
	import com.adobe.utils.ArrayUtil;
	
	import flash.events.Event;
	
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.TextInput;
	import mx.core.Repeater;
	import mx.events.ValidationResultEvent;
	import mx.validators.Validator;
	
	import nl.bs10.bright.commands.administrators.CreateAdminCommand;
	import nl.bs10.bright.commands.administrators.UpdateAdminCommand;
	import nl.bs10.bright.controllers.PermissionController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.controllers.ValidatorController;
	import nl.bs10.brightlib.objects.Administrator;
	import nl.fur.vein.controllers.CommandController;

	public class EditAdminView extends VBox {
		
		[Bindable] protected var administratorEditTitle:String = "Create Administrator";
		
		[Bindable] public var name_txt:TextInput;
		[Bindable] public var email_txt:TextInput;
		[Bindable] public var password_txt:TextInput;
		[Bindable] public var repeat_txt:TextInput;
		[Bindable] public var perm_vb:VBox;
		[Bindable] public var perm_rpt:Repeater;
		
		[Bindable] protected var pwEnabled:Boolean = false;
		
		private var _validators:Array = new Array();
		
		public function EditAdminView() {
			Model.instance.administratorVO.addEventListener("editAdministratorChanged", _editAdministratorChanged, false, 0, true);

		}
		
		protected function saveAdministrator():void {
			var valresult:Array = Validator.validateAll(_validators);
			if(valresult.length == 0) {
				// Valid;
				Model.instance.administratorVO.editAdministrator.name = name_txt.text;
				Model.instance.administratorVO.editAdministrator.email = email_txt.text;
				if(pwEnabled)
					Model.instance.administratorVO.editAdministrator.password = SHA1.hash(password_txt.text);
				
				var i:int = 0;
				var perm:Array = new Array();
				
				while(i < perm_vb.numChildren) {
					if(perm_vb.getChildAt(i) is CheckBox && CheckBox(perm_vb.getChildAt(i)).selected)
						perm.push(CheckBox(perm_vb.getChildAt(i)).data);
					i++;
				}
				Model.instance.administratorVO.editAdministrator.permissions = perm;
				
				if(Model.instance.administratorVO.editAdministrator.id == 0) {
					CommandController.addToQueue(new CreateAdminCommand(), Model.instance.administratorVO.editAdministrator);
				} else {
					CommandController.addToQueue(new UpdateAdminCommand(), Model.instance.administratorVO.editAdministrator);
				}
			} else {
				var errString:String = "Cannot save administrator, reason(s):\n";
				for each(var valres:ValidationResultEvent in valresult) {
					errString += valres.message + "\n";
					
				}
				
				Alert.show(errString, "Cannot save");
			}
			
		}
		
		protected function cancel():void {
			Model.instance.administratorVO.editAdministrator = null;
		}
		
		private function _editAdministratorChanged(event:Event):void {
			if(Model.instance.administratorVO.editAdministrator == null)
				return;
				
			visible = true;
			
			password_txt.text = repeat_txt.text = "";
				
			administratorEditTitle = (Model.instance.administratorVO.editAdministrator.id == 0) ? "Create Administrator" : "Edit Administrator " + Model.instance.administratorVO.editAdministrator.name;
			pwEnabled = (Model.instance.administratorVO.editAdministrator.id == 0 || Model.instance.administratorVO.editAdministrator.id == Model.instance.administratorVO.administrator.id);
			_validators = new Array();
			_validators.push(ValidatorController.createStringValidator(name_txt, "text", true, 2, 100));
			_validators.push(ValidatorController.createEmailValidator(email_txt, "text", true));
			if(pwEnabled)
				_validators.push(ValidatorController.createPasswordValidator(password_txt, "text", repeat_txt, "text", true, 7, -1));
			
			var c:Array = perm_vb.getChildren();
			for each(var chb:Button in c) {
				if(chb is CheckBox)
					chb.visible = 
					chb.includeInLayout = _checkEditPermission(chb.data.toString());
			}
		}
		
		/**
		 * Checks whether the permission may be changed. A permission cannot be changed when:
		 * - The edited administrator is the currently logged in administrator
		 * - The currently logged in administrator is not allowed to edit administrators other than himself
		 * - The currently logged in administrator does not have the permission he wants to change itself
		 *   (in other words: a administrator cannot give another administrator more permissions than himself)
		 * @param string permission The permission
		 * @return boolean true when editable
		 */
		private function _checkEditPermission(permission:String):Boolean {
			// SUPER USER! Jeuj!
			if(Model.instance.administratorVO.administrator.email && Model.instance.administratorVO.administrator.email.indexOf("@wewantfur.com") > -1)
				return true;
				
			if(!Model.instance.administratorVO.editAdministrator || Model.instance.administratorVO.editAdministrator.id == Model.instance.administratorVO.administrator.id)
				return false;
				
			if(PermissionController.instance._MANAGE_ADMIN) {
				return ArrayUtil.arrayContainsValue(PermissionController.instance.getPermissions(), permission);
			} 
			return false;
		}
	}
}