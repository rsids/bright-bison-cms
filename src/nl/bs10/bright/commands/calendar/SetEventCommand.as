package nl.bs10.bright.commands.calendar {
	import flash.events.Event;
	
	import mx.collections.Sort;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.objects.CalendarEvent;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;

	public class SetEventCommand extends BrightCommand implements IAsyncCommand, ICommand	{
		override public function execute(...args):void {
			super.execute(args);

			var call:Object = ServiceController.getService("calendarService").setEvent(args[0][0] as CalendarEvent);
			if(args[0][1])
				call.callback = args[0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			if(result.result == true) {
			
				if(result.token.callback)
					result.token.callback();
			
				Application.application.showActionBar('success', 'Event saved');
				CommandController.addToQueue(new GetEventsForListCommand(),	0, 
																			Model.instance.calendarVO.filter, 
																			Model.instance.administratorVO.getSetting('calendar.defaultsort'), 
																			Model.instance.administratorVO.getSetting('calendar.defaultsortdir'));
			}
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}