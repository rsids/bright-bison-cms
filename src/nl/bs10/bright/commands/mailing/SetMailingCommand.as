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

	public class SetMailingCommand extends BrightCommand implements IAsyncCommand, ICommand	{
		override public function execute(...args):void {
			super.execute(args);

			var call:Object = ServiceController.getService("mailingService").setMailing(args[0][0] as Page);
			if(args[0][1])
				call.callback = args[0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			for each(var page:Page in result.result.mailings) {
				Model.instance.mailingVO.mailings[page.pageId] = page;
			}
			
			Model.instance.mailingVO.updateMailings();
			
			
			Model.instance.mailingVO.currentItem = result.result.mailing;
			
			if(result.token.callback)
				result.token.callback();
			
			Application.application.showActionBar('success', 'Mailing saved');

			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}