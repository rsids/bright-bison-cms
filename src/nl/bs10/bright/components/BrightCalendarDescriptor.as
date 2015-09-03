package nl.bs10.bright.components {
	import com.hevery.cal.CalendarDescriptor;
	
	import flash.events.Event;
	
	import nl.bs10.bright.model.Model;
	
	public class BrightCalendarDescriptor implements CalendarDescriptor {
		
		public function getCalendarColor(calendar:*):Number {
			return calendar.color;
		}
		
		public function getCalendarName(calendar:*):String {
			return calendar.name;
		}
		
		public function getCalendar(event:*):* {
			return Model.instance.calendarVO.events[event.calendarId].calendar;
		}
		
		
		
		public function getEventStart(event:*):Date {
			if(!event)
				return null;
			
			return event.flstarttime;
		}
		
		public function getEventEnd(event:*):Date {
			if(!event)
				return null;
			return event.flendtime;
		}
		
		public function getEventTitle(event:*):String {
			if(!event)
				return null;
			return Model.instance.calendarVO.events[event.calendarId].label;//'what'; //event.what;
		}
		
		public function getEventDescription(event:*):String {
			return '';//'description'; //event.description;
		}
		
		public function getEventColor(event:*):Number {
			if(!event)
				return NaN;
			return Model.instance.calendarVO.events[event.calendarId].calendar.color;
		}
		
		public function getAllDay(event:*):Boolean {
			if(!event)
				return false;
			return event.allday;
		}
			
	}
}