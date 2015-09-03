package nl.bs10.bright.commands.page {
	
	import flash.events.Event;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetUpdatedPagesCommand extends BrightCommand implements ICommand, IAsyncCommand {
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("pageService").getUpdatedPages();
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var s:Sort = Model.instance.pageVO.apages.sort;
			for each(var co:Page in result.result) {
				Model.instance.pageVO.pages[co.pageId] = co;
			}
			
			Model.instance.pageVO.pagesChanged = !Model.instance.pageVO.pagesChanged;
			Model.instance.pageVO.apages.sort = s;
			Model.instance.administratorVO.administrator.labelsChanged();
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}