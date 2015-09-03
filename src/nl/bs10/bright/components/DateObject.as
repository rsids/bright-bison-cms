package nl.bs10.bright.components
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Bindable]
	public class DateObject extends EventDispatcher
	{
		public function DateObject(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public var startDate:Date;
		public var endDate:Date;
		public var startTime:int;
		public var endTime:int;
		
		public var allDay:Boolean;
		public var noEndTime:Boolean;
	}
}