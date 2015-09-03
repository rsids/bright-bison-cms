package nl.bs10.bright.commands.administrators {
	import com.adobe.crypto.SHA1;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.managers.PopUpManager;
	import mx.rpc.Fault;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.commands.config.CallInitCommands;
	import nl.bs10.bright.controllers.PermissionController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Administrator;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.events.VeinDispatcher;

	public class AuthenticateCommand extends BrightCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args:Array):void {
			var email:String = args[0][0];
			var password:String = args[0][1];
			password = SHA1.hash(password);
			var call:Object = ServiceController.getService("adminService").authenticate(email, password);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;	
			super.execute(args);		
		}

		override public function resultHandler(event:Event):void {
			var resultEvent:ResultEvent = event as ResultEvent;
			if(resultEvent.result) {
				var usr:Administrator  =
				Model.instance.administratorVO.administrator = resultEvent.result as Administrator;
				PermissionController.instance.setPermissions(Model.instance.administratorVO.administrator.permissions);
				
				if(!PermissionController.instance._IS_AUTH) 
					return super.resultHandler(event);
				
				PopUpManager.removePopUp(Model.instance.applicationVO.loginView);
				
				// Init allready done, session expired, no need to get new data
				if(Model.instance.applicationVO.applicationState >= 1)
					return super.resultHandler(event);
					
				if(PermissionController.instance._MANAGE_ADMIN)
					Model.instance.administratorVO.administratorActions = ["Create User", "Edit User", "Delete User"];
				CommandController.addToQueue(new CallInitCommands());
				
			} else {
				Alert.show("Invalid email address - password combination, please try again", "Login failed");
				VeinDispatcher.instance.dispatch('authenticateResult', false);
			}
			super.resultHandler(event);
		}
		override public function faultHandler(event:Event):void {
			var fault:Fault = event["fault"];
			Alert.show("An error occured during the request, details:\n" + fault.faultString, "Error");
			super.faultHandler(event);
		}
		
	}
}