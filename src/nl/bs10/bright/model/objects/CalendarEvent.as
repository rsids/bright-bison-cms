package nl.bs10.bright.model.objects
{
	import flash.events.Event;
	import flash.utils.describeType;
	
	import nl.bs10.bright.components.BrightCalendarDescriptor;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.Page;

	[RemoteClass(alias="OCalendarEvent")]
	public dynamic class CalendarEvent extends Page
	{
		
		private var _allday:Boolean;
		private var _calendar:Object;
		private var _calendarId:int;
		private var _dates:Array;
		private var _enddate:int;
		private var _fluntil:Date = new Date(new Date().fullYear +1, new Date().month,new Date().date,0,0,0,0);
		private var _locationId:int;
		private var _modificationdate:uint;
		private var _repeat:Boolean;
		private var _recur:String = '';
		private var _startdate:int;
		private var _until:int;
		
		public function CalendarEvent() {
			flexpirationdate = new Date(new Date().fullYear, new Date().month,new Date().date+1,0,0,0,0);
		}
		
		[Bindable(event="alldayChanged")]
		public function set allday(value:Boolean):void {
			if(value != _allday) {
				_allday = value;
				dispatchEvent(new Event("alldayChanged"));
			}
		}		
		
		public function get allday():Boolean {
			return _allday;
		}
		
		
		[Bindable(event="calendarIdChanged")]
		public function set calendarId(value:int):void {
			if(value !== _calendarId) {
				_calendarId = value;
				// Set for editor, not used
				dispatchEvent(new Event("calendarIdChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the calendarId property
		 **/
		public function get calendarId():int {
			return _calendarId;
		}
		
		
		[Bindable(event="datesChanged")]
		public function set dates(value:Array):void {
			if(value !== _dates) {
				_dates = value;
				dispatchEvent(new Event("datesChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the dates property
		 **/
		public function get dates():Array {
			return _dates;
		}
		
		private var _enabled:Boolean = true;
		
		[Bindable(event="enabledChanged")]
		public function set enabled($value:Boolean):void {
			if($value !== _enabled) {
				_enabled = $value;
				dispatchEvent(new Event("enabledChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the enabled property
		 **/
		public function get enabled():Boolean {
			return _enabled;
		}
		
		[Bindable(event="locationIdChanged")]
		public function set locationId(value:int):void {
			if(value !== _locationId) {
				_locationId = value;
				dispatchEvent(new Event("locationIdChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the locationId property
		 **/
		public function get locationId():int {
			return _locationId;
		}
		
		private var _rawdates:Array;
		
		[Bindable(event="rawdatesChanged")]
		public function set rawdates(value:Array):void {
			if(value !== _rawdates) {
				_rawdates = value;
				dispatchEvent(new Event("rawdatesChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the rawdates property
		 **/
		public function get rawdates():Array {
			return _rawdates;
		}
		
		[Bindable(event="recurChanged")]
		public function set recur(value:String):void {
		 	if(value !== _recur) {
		 		_recur = value;
		 		dispatchEvent(new Event("recurChanged"));
		 	}
		}		
		
		public function get recur():String {
			return _recur;
		}
		
		
		[Bindable(event="untilChanged")]
		public function set until(value:int):void {
			fluntil = new Date(value * 1000);
		 	dispatchEvent(new Event("untilChanged"));
		}		
		
		public function get until():int {
			return fluntil.getTime() / 1000;
		}
		
		[Transient]
		[Bindable(event="fluntilChanged")]
		public function set fluntil(value:Date):void {
			if(value !== _fluntil) {
				_fluntil = value;
				dispatchEvent(new Event("fluntilChanged"));
			}
		}
		
		public function get fluntil():Date {
			return _fluntil;
		}
		
		[Transient]
		[Bindable(event="calendarChanged")]
		public function set calendar(value:Object):void {
			if(value !== _calendar) {
				_calendar = value;
				dispatchEvent(new Event("calendarChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the calendar property
		 **/
		public function get calendar():Object {
			return _calendar;
		}

	
		[Transient]
		override public function clone():IPage {
		
			var clone:CalendarEvent = new CalendarEvent();
			var description:XML = describeType(this);
			for each(var accessor:XML in description..accessor) {
				var prop:String = accessor.@name;
				clone[prop] = this[prop];
			}
			return clone;
		}
	}
}