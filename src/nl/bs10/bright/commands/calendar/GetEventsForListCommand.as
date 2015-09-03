package nl.bs10.bright.commands.calendar
{
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.controllers.SettingsController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.objects.CalendarEvent;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	
	public class GetEventsForListCommand extends BaseCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			Model.instance.applicationVO.isLoading = true;
			switch(args[0][2]) {
				case 'flpublicationdate':
				case 'flmodificationdate':
				case 'flexpirationdate':
				case 'flcreationdate':
					args[0][2] = args[0][2].substr(2);
			}
			var call:Object = ServiceController.getService("calendarService").getEventsByIdRange(args[0][0], 80, args[0][1], args[0][2], args[0][3]);
			call.start = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
				
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;	
			var co:CalendarEvent;
			Model.instance.calendarVO.totalEvents = result.result.total;
			
			if(result.token.start == 0) {
				if(Model.instance.calendarVO.aevents) {
					Model.instance.calendarVO.aevents.removeAll();
				}
				Model.instance.calendarVO.aevents = new ArrayCollection();
			}
			
			for each(co in result.result.result) {
				co.calendar = Model.instance.calendarVO.calendarHashmap[co.itemType];
				Model.instance.calendarVO.events[co.calendarId] = co;
				Model.instance.calendarVO.aevents.addItem(co);
			}
			var sf:String = (Model.instance.administratorVO.getSetting('calendar.defaultsort') != null) ?  Model.instance.administratorVO.getSetting('calendar.defaultsort') :'calendarId';
			
			// Quick fix
			if(sf == 'location') {
				sf = 'locationId';
			}
			
			var ce:CalendarEvent = new CalendarEvent();
			if(!ce.hasOwnProperty(sf))
				sf = 'calendarId';
			var desc:Boolean = Model.instance.administratorVO.getSetting('calendar.defaultsortdir') != 'ASC';
			var s:Sort = new Sort();
			s.fields = [new SortField(sf, false, desc, true)];
			Model.instance.calendarVO.aevents.sort = s;
			Model.instance.calendarVO.aevents.refresh();
			
			SettingsController.setLabels(Model.instance.calendarVO.events, 'calendar');
			
			
			if(result.result.result.length == 0) {
				Application.application.showActionBar('info', 'Search returned 0 results');
			}
			
			Model.instance.applicationVO.isLoading = false;
			super.resultHandler(event);
		}
				
		override public function faultHandler(event:Event):void {
			Model.instance.applicationVO.isLoading = false;
			super.faultHandler(event);
		}
	}
}