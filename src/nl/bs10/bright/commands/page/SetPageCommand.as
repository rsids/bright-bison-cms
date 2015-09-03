package nl.bs10.bright.commands.page {
	import flash.events.Event;
	
	import mx.collections.Sort;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	import nl.flexperiments.tree.FlpTree;
	import nl.flexperiments.tree.Node;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SetPageCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			if(!args[0][0] || args[0][0] == null)
				return super.resultHandler(new Event("fakeevent"));
				
			var call:Object = ServiceController.getService("pageService").setPage(args[0][0] as Page);
			if(args[0][1])
				call.callback = args[0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var flptree:FlpTree = Model.instance.structureVO.tree;
			var s:Sort = Model.instance.pageVO.apages.sort;
			for each(var page:Page in result.result) {
					 
				Model.instance.pageVO.pages[page.pageId] = page;
				
				
				// Update tree!
				var arr:Array = flptree.findNodes("data.page.pageId", page.pageId);
				for each(var node:Node in arr) {
					node.data.page = page;
				}
			}

			Model.instance.pageVO.pagesChanged = !Model.instance.pageVO.pagesChanged;
			Model.instance.pageVO.apages.sort = s;
			Model.instance.administratorVO.administrator.labelsChanged();
			
			Model.instance.structureVO.structure.refresh();
			flptree.refresh();

			
			if(result.token.callback)
				result.token.callback();
			
			Application.application.showActionBar('success', 'Page saved');
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}