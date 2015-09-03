package nl.bs10.bright.commands.mailing
{
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SendTestMailCommand extends BrightCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			var ci:* = Model.instance.mailingVO.currentItem;
			var call:Object = ServiceController.getService("mailingService").sendTest(ci.pageId, args[0][0]);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			
			Alert.show("The mail has been send.\r\nCheck your e-mail", "Success");
			
			Application.application.showActionBar('info', 'Mail send');

			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}