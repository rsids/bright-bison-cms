package nl.bs10.bright.commands.page {
	import flash.events.Event;
	
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.utils.Log;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GenerateLabelCommand extends BrightCommand implements IAsyncCommand, ICommand
	{
		override public function execute(...args):void {
			super.execute(args);
			var service:String = "pageService";
			var id:String = 'pageId';
			
			// Calendars have their own set of labels
			if(args[0][1] == 'calendar') {
				service = 'calendarService';
				id = 'calendarId';	
			}
			var call:Object = ServiceController.getService(service).generateLabel(args[0][0].currentItem.label, args[0][0].currentItem[id]);
			call.current = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			if(result.token.current.currentItem) {
				result.token.current.currentItem.label = result.result as String;
			}
			
			Log.add("Label updated to " + (result.result as String));
				
			super.resultHandler(event);
		}
		
	}
}