package nl.bs10.bright.commands.calendar {
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.objects.CalendarDateObject;
	import nl.bs10.bright.model.objects.CalendarEvent;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	
	public class GetEventsForCalendarCommand extends BaseCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			var d1:Date = new Date(Model.instance.calendarVO.selectedDate.getTime());
			d1.setMonth(d1.getMonth()-1);
			var d2:Date = new Date(Model.instance.calendarVO.selectedDate.getTime());
			d2.setMonth(d2.getMonth()+1);
			
			Model.instance.applicationVO.isLoading = true;
			
			var call:Object = ServiceController.getService("calendarService").getEvents(d1.getTime() / 1000, d2.getTime() / 1000, true, args[0][0]);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;	
			var co:CalendarEvent;
			Model.instance.calendarVO.calendarEvents = new ArrayCollection();
			Model.instance.calendarVO.calendarEvents.removeAll();
			Model.instance.calendarVO.events = new Array();
			for each(co in result.result) {
				co.calendar = Model.instance.calendarVO.calendarHashmap[co.itemType];
				Model.instance.calendarVO.events[co.calendarId] = co;
				for each(var cdo:CalendarDateObject in co.rawdates) {
					Model.instance.calendarVO.calendarEvents.addItem(cdo);
				}
			}
			
			Model.instance.calendarVO.calendarEvents.refresh();
			if(result.result.length == 0) {
				Application.application.showActionBar('info', 'Search returned 0 results');
			}
			Model.instance.applicationVO.isLoading = false;
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			Application.application.showActionBar('error', 'Something went wrong...');
			
			super.faultHandler(event);
			Model.instance.applicationVO.isLoading = false;
		}
	}
}