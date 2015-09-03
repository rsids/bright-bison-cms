package nl.bs10.bright.model.vo {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import nl.bs10.bright.commands.calendar.SetEventCommand;
	import nl.bs10.bright.model.objects.CalendarEvent;
	import nl.bs10.brightlib.interfaces.IContentVO;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.fur.vein.controllers.CommandController;
	
	public class CalendarVO extends MultiLangVO implements IContentVO {
		
		private var _currentItem:IPage;
		private var _currentEvent:CalendarEvent;
		private var _acalendars:ArrayCollection = new ArrayCollection();
		private var _aevents:ArrayCollection = new ArrayCollection();
		
		private var _repeatoptions:ArrayCollection;
		
		private var _totalEvents:int = 0;
		
		private var _selectedDate:Date;
		
		public var calendarHashmap:Array;
		[Bindable] public var events:Array = new Array();
		
		public var filter:*;
		
		public function CalendarVO() {
			super();
			repeatoptions = new ArrayCollection([	{data:'DAILY', label:"Day", plural:"days"}, 
													{data:'WEEKLY', label:"Week", plural:"weeks"}, 
													{data:'MONTHLY', label:"Month", plural:"months"}, 
													{data:'YEARLY', label:"Year", plural:"years"}]);

		}
		
		
		[Bindable(event="calendarsChanged")]
		public function set acalendars(value:ArrayCollection):void {
			if(value !== _acalendars) {
				_acalendars = value;
				dispatchEvent(new Event("calendarsChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the calendars property
		 **/
		public function get acalendars():ArrayCollection {
			return _acalendars;
		}
		
		/**
		 * Holds the events shown in the list view of the calendar
		 */
		[Bindable(event="aeventsChanged")]
		public function set aevents(value:ArrayCollection):void {
			if(_aevents !== value) {
				_aevents = value;
				var ne:uint = value.length;
				dispatchEvent(new Event("aeventsChanged"));
			}
		}
		
		public function get aevents():ArrayCollection {
			return _aevents;
		}
		
		private var _calendarEvents:ArrayCollection;
		
		/**
		 * Holds the events shown in the month or week view of the calendar
		 */ 
		[Bindable(event="calendarEventsChanged")]
		public function set calendarEvents(value:ArrayCollection):void {
			if(value !== _calendarEvents) {
				_calendarEvents = value;
				dispatchEvent(new Event("calendarEventsChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the calendarEvents property
		 **/
		public function get calendarEvents():ArrayCollection {
			return _calendarEvents;
		}

		[Bindable(event="ItemChanged")] 
		override public function set currentItem(value:IPage):void {
			if(_currentItem !== value) {
				_currentItem = value as CalendarEvent;
				currentEvent = value as CalendarEvent;
				dispatchEvent(new Event("ItemChanged"));
			}
		}
		
		override public function get currentItem():IPage {
			return _currentEvent;
		}

		[Bindable(event="eventChanged")] 
		public function set currentEvent(value:CalendarEvent):void {
			if(_currentEvent !== value) {
				_currentEvent = value;
				dispatchEvent(new Event("eventChanged"));
			}
		}
		
		public function get currentEvent():CalendarEvent {
			return _currentEvent;
		}

		[Bindable(event="repeatoptionsChanged")] 
		public function set repeatoptions(value:ArrayCollection):void {
			if(_repeatoptions !== value) {
				_repeatoptions = value;
				dispatchEvent(new Event("repeatoptionsChanged"));
			}
		}
		
		public function get repeatoptions():ArrayCollection {
			return _repeatoptions;
		}
		
		[Bindable(event="selectedDateChanged")]
		public function set selectedDate(value:Date):void {
			if(value !== _selectedDate) {
				_selectedDate = value;
				dispatchEvent(new Event("selectedDateChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the selectedDate property
		 **/
		public function get selectedDate():Date {
			return _selectedDate;
		}
		
		public function setCalendars(value:Array):void {
			calendarHashmap = value;
			var arr:Array = new Array();
			for each(var co:* in calendarHashmap) {
				arr.push(co);
			}
			var s:Sort = acalendars.sort;
			acalendars = new ArrayCollection(arr);
			acalendars.sort = s;
			acalendars.refresh();
		}
		
		[Bindable(event="totalEventsChanged")]
		public function set totalEvents(value:int):void {
			if(value !== _totalEvents) {
				_totalEvents = value;
				dispatchEvent(new Event("totalEventsChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the totalEvents property
		 **/
		public function get totalEvents():int {
			return _totalEvents;
		}
		
		override public function save(callback:Function):void {
			CommandController.addToQueue(new SetEventCommand(), currentItem, callback);
		}
	}
}