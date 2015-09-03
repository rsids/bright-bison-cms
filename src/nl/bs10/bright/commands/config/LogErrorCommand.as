package nl.bs10.bright.commands.config
{
	import flash.events.Event;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class LogErrorCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("settingsService").logError(args[0][0]);
			call.resultHandler = resultHandler;
			call.faultHandler = faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}