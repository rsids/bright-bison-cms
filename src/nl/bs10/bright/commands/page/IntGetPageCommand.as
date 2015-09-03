package nl.bs10.bright.commands.page
{
	import flash.events.Event;
	
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	
	internal class IntGetPageCommand extends BrightCommand implements IAsyncCommand, ICommand {
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("pageService").getPageById(args[0][0][0], false, true);
			call.callback = args[0][0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			var page:Page = (result.result as Page);
			if(Model.instance.applicationVO.config.general.hasOwnProperty("overviewfields")) {
				for each(var field:String in Model.instance.applicationVO.config.general.overviewfields) {
					if(page.content.hasOwnProperty(field) && page.content[field] != null && page.content[field].hasOwnProperty(Model.instance.applicationVO.config.general.languages[0]))
						page[field] = page.content[field][Model.instance.applicationVO.config.general.languages[0]].toString();
				}
			}
			Model.instance.pageVO.pages[page.pageId] = page;
			Model.instance.pageVO.pagesChanged = !Model.instance.pageVO.pagesChanged;
			result.token.callback(Model.instance.pageVO.pages[page.pageId]);
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
	}
}