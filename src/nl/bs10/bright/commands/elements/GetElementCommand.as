package nl.bs10.bright.commands.elements{
	
	import flash.events.Event;
	
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetElementCommand extends BrightCommand implements ICommand, IAsyncCommand {
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("pageService").getPageById(args[0][0], false, true);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var page:Page = (result.result as Page);
			Model.instance.elementVO.currentItem = page;
			super.resultHandler(event);
		}
	}
}