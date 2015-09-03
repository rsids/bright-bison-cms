package nl.bs10.bright.commands.administrators
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	import mx.rpc.Fault;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.Version;
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.commands.config.CallInitCommands;
	import nl.bs10.bright.controllers.PermissionController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.views.login.LoginView;
	import nl.bs10.bright.views.login.LoginViewLayout;
	import nl.bs10.brightlib.objects.Administrator;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;
	
	/**
	 * Checks if an administrator is (already) logged in. Also, it sends the FE version, to check if database updates are needed 
	 * @author BS10
	 * 
	 */	
	public class IsAuthCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args:Array):void {
			var call:Object = ServiceController.getService("adminService").isAuth(Version.VERSION);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;	
			super.execute(args);		
		}

		override public function resultHandler(event:Event):void {
			var resultEvent:ResultEvent = event as ResultEvent;
			Model.instance.applicationVO.loginView = PopUpManager.createPopUp(Application.application as DisplayObject, LoginViewLayout, true);
			if(resultEvent.result !== false) {
				var usr:Administrator  =
				Model.instance.administratorVO.administrator = resultEvent.result as Administrator;
				PermissionController.instance.setPermissions(Model.instance.administratorVO.administrator.permissions);
				
				if(!PermissionController.instance._IS_AUTH) {
					//LoginView(Model.instance.applicationVO.loginView).viewId = "loginView";
					PopUpManager.centerPopUp(Model.instance.applicationVO.loginView);
					 
					return super.resultHandler(event);
				}
				
				if(PermissionController.instance._MANAGE_ADMIN)
					Model.instance.administratorVO.administratorActions = ["Create Administrator", "Edit Administrator", "Delete Administrator"];
				
				CommandController.addToQueue(new CallInitCommands());
				PopUpManager.removePopUp(Model.instance.applicationVO.loginView);
			} else {
				
				//LoginView(Model.instance.applicationVO.loginView).viewId = "loginView";
				PopUpManager.centerPopUp(Model.instance.applicationVO.loginView);
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