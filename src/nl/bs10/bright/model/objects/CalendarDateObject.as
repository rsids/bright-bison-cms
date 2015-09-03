package nl.bs10.bright.model.objects
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[RemoteClass(alias="OCalendarDateObject")]
	public class CalendarDateObject extends EventDispatcher implements IEventDispatcher
	{
		private var _flstarttime:Date;
		private var _flendtime:Date;
		private var _allday:Boolean;
		private var _noend:Boolean;
		private var _calendarId:uint;
		
		public var eventId:int;
		
		public function CalendarDateObject(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		[Bindable(event="calendarIdChanged")]
		public function set calendarId(value:uint):void {
			if(value !== _calendarId) {
				_calendarId = value;
				dispatchEvent(new Event("calendarIdChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the calendarId property
		 **/
		public function get calendarId():uint {
			return _calendarId;
		}
		
		public function set starttime(value:uint):void {
				flstarttime = new Date(value * 1000);
		}
		
		/** 
		 * Getter/Setter methods for the fromDate property
		 **/
		public function get starttime():uint {
			return Math.round(flstarttime.getTime() / 1000);
		}
		
		[Bindable(event="todateChanged")]
		public function set endtime(value:uint):void {
			flendtime = new Date(value * 1000);
		}
		
		/** 
		 * Getter/Setter methods for the todate property
		 **/
		public function get endtime():uint {
			return Math.round(flendtime.getTime() / 1000);
		}
		
		[Transient]
		[Bindable(event="flstarttimeChanged")]
		public function set flstarttime(value:Date):void {
			if(value !== _flstarttime) {
				_flstarttime = value;
				dispatchEvent(new Event("flstarttimeChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the flstarttime property
		 **/
		public function get flstarttime():Date {
			return _flstarttime;
		}
		
		[Transient]
		[Bindable(event="flendtimeChanged")]
		public function set flendtime(value:Date):void {
			if(value !== _flendtime) {
				_flendtime = value;
				dispatchEvent(new Event("flendtimeChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the flendtime property
		 **/
		public function get flendtime():Date {
			return _flendtime;
		}
		
		[Bindable(event="alldayChanged")]
		public function set allday(value:Boolean):void {
			if(value !== _allday) {
				_allday = value;
				dispatchEvent(new Event("alldayChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the allday property
		 **/
		public function get allday():Boolean {
			return _allday;
		}
		
		[Bindable(event="noendChanged")]
		public function set noend(value:Boolean):void {
			if(value !== _noend) {
				_noend = value;
				dispatchEvent(new Event("noendChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the noend property
		 * Indicates whether the event has a (visible) end time
		 **/
		public function get noend():Boolean {
			return _noend;
		}
		
		[Transient]
		public function clone():CalendarDateObject {
			var c:CalendarDateObject = new CalendarDateObject();
			c.noend = noend;
			c.allday = allday
			c.calendarId = calendarId;
			c.starttime = starttime;
			c.endtime = endtime;
			return c;
		}
	}
}