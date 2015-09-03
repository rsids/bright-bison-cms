package nl.bs10.bright.commands.page {
	
	import flash.events.Event;
	import flash.net.FileReference;
	
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SearchPagesCommand extends BrightCommand implements ICommand, IAsyncCommand {

		override public function execute(...args):void {
			super.execute(args);
				
			var call:Object = ServiceController.getService("pageService").search(args[0][0], 0, -1, true);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			Model.instance.pageVO.filterPageIds = new Array();
			for each(var id:int in result.result) {
				Model.instance.pageVO.filterPageIds[id] = true;
			}
			Model.instance.pageVO.apages.refresh();
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}