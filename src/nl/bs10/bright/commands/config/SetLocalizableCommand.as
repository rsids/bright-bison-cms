package nl.bs10.bright.commands.config
{
	import flash.events.Event;
	
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	
	public class SetLocalizableCommand extends BrightCommand implements IAsyncCommand, ICommand
	{
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("configService").setLocalizableFields(args[0][0]);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			Model.instance.applicationVO.localizablefields = result.result;
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}