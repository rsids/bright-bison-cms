package nl.bs10.bright.commands.administrators {
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class LogoutCommand extends BrightCommand implements ICommand, IAsyncCommand {

		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("adminService").logoutcmd();
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			Model.instance.applicationVO.applicationState = 0;
			ExternalInterface.call("reload");
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}