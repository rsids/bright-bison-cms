package nl.bs10.bright.commands {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Proxy;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	import mx.rpc.Fault;
	
	import nl.bs10.bright.commands.administrators.AuthenticateCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;

	public class BrightCommand extends nl.fur.vein.commands.BaseCommand {
		private var _args:Array;
		
		override public function execute(...args):void {
			if(this is IAsyncCommand)
				Model.instance.applicationVO.commandExecuting = true;
			_args = args;
			super.execute(args);
			
		}
		
		override public function resultHandler(event:Event):void {
			Model.instance.applicationVO.commandExecuting = false;
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void	{
			Model.instance.applicationVO.commandExecuting = false;
			var fault:Fault = event["fault"];
			var fc:Number = Number(fault.faultCode);
			if(fc == 1001) {
				// Login
				var now:Date = new Date();
				if( Model.instance.administratorVO.lastLoginAttempt && now.getTime() - Model.instance.administratorVO.lastLoginAttempt.getTime() < 3600000) {
					// Within an hour, reconnect automatically
					CommandController.addToQueue(new AuthenticateCommand(), Model.instance.administratorVO.lastLoginEmail, Model.instance.administratorVO.lastLoginPassword);
					
					// Add this command to the qeue again
					getQualifiedClassName(this);
					var objClass:Class = Class(getDefinitionByName(getQualifiedClassName(this)));
					var arr:Array = [new objClass()];
					arr = arr.concat(_args[0][0]);
					trace(arr);
					CommandController.addToQueue.apply(null, arr);
				} else {
					PopUpManager.addPopUp(Model.instance.applicationVO.loginView, Application.application as DisplayObject, true);
					PopUpManager.centerPopUp(Model.instance.applicationVO.loginView);
					Alert.show("Your session has expired, please login again", "Session expired");
					
				}
			} else if(fc > 1000 && fc < 10000) {
				// Bright error, show message
				Alert.show(fault.faultString, "Error");
			} else if(fault.faultCode.indexOf("AMFPHP") == 0) {
				// AMF Error, could be useful
				Alert.show(fault.faultString, "Error");
			} else {
				// General server error
				Alert.show("An error occured, please try again", "Error");
			}
			super.faultHandler(event);
		}
		
	}
}