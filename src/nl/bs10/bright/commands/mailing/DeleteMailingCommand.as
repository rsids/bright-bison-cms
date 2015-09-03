package nl.bs10.bright.commands.mailing {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class DeleteMailingCommand extends BrightCommand implements IAsyncCommand, ICommand	{
		override public function execute(...args):void {
			super.execute(args);

			var call:Object = ServiceController.getService("mailingService").deleteMailing(args[0][0]);
			call.pageId = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			if(Model.instance.mailingVO.currentItem && Model.instance.mailingVO.currentItem.pageId == result.token.pageId) {
				Model.instance.mailingVO.currentItem = null;
			}
			
			delete Model.instance.mailingVO.mailings[result.token.pageId];
			
			for each(var page:Page in result.result as Array) {
				Model.instance.mailingVO.mailings[page.pageId] = page;
			}
			
			Model.instance.mailingVO.updateMailings();
			
			Application.application.showActionBar('delete', 'Mailing deleted');

			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}