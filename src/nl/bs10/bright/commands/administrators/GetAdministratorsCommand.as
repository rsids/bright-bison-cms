package nl.bs10.bright.commands.administrators {
	
	import flash.events.Event;
	
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetAdministratorsCommand extends BrightCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args):void {
			super.execute(args);
			Model.instance.applicationVO.loadingInfo = "Loading users";
			
			var call:Object = ServiceController.getService("adminService").getAdministrators();
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			Model.instance.administratorVO.administrators = result.result as Array;
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			Model.instance.applicationVO.loadingInfo = "Loading users FAILED";
			super.faultHandler(event);
		}
		
	}
}