package nl.bs10.bright.commands.page
{
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class DeletePageCommand extends BrightCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args):void {
			super.execute(args);
			var pids:Array = new Array();
			for each(var page:Page in args[0][0]) {
				pids.push(page.pageId);
			}
			
			var call:Object = ServiceController.getService("pageService").deletePages(pids);
			call.pids = pids;
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			if(result.result == true) {
				for each(var pid:int in result.token.pids) {
				Model.instance.pageVO.apages.removeItemAt(Model.instance.pageVO.apages.getItemIndex(Model.instance.pageVO.pages[pid]));
				delete Model.instance.pageVO.pages[pid];
				}
			}
			Application.application.showActionBar('delete', 'Page deleted');
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}