package nl.bs10.bright.commands.template
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetParsersCommand extends BrightCommand implements IAsyncCommand, ICommand {
	
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("templateService").getParsers();
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			Model.instance.templateVO.parsers = new ArrayCollection(result.result as Array);
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}