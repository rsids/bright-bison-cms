package nl.bs10.bright.views.calendar {
	
	import com.adobe.utils.ArrayUtil;
	import com.hevery.cal.Calendar;
	import com.hevery.cal.NullCalendarDescriptor;
	import com.hevery.cal.SelectDay;
	import com.hevery.cal.event.CalendarEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.collections.SortField;
	import mx.containers.HDividedBox;
	import mx.containers.VBox;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.TabBar;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.events.CalendarLayoutChangeEvent;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	import mx.events.DropdownEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.calendar.DeleteEventsCommand;
	import nl.bs10.bright.commands.calendar.GetEventCommand;
	import nl.bs10.bright.commands.calendar.GetEventsForCalendarCommand;
	import nl.bs10.bright.commands.calendar.GetEventsForListCommand;
	import nl.bs10.bright.components.BrightCalendarDescriptor;
	import nl.bs10.bright.components.BrightDataGrid;
	import nl.bs10.bright.components.CalEvent;
	import nl.bs10.bright.controllers.SettingsController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.objects.CalendarDateObject;
	import nl.bs10.bright.model.objects.CalendarEvent;
	import nl.bs10.bright.model.vo.TemplateVO;
	import nl.bs10.bright.views.settings.DataGridSettingsViewLayout;
	import nl.bs10.brightlib.components.BrightDateField;
	import nl.bs10.brightlib.controllers.DatagridController;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.objects.Template;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.events.VeinDispatcher;
	import nl.fur.vein.events.VeinEvent;

	public class CalendarView extends HDividedBox {
		
		[Bindable] public var calendar_dg:BrightDataGrid;
		[Bindable] public var dg_vbox:VBox;
		[Bindable] public var cal_vs:ViewStack;
		[Bindable] public var cal_tb:TabBar;
		[Bindable] public var filter_txt:TextInput;
		[Bindable] public var calStartDs:BrightDateField;
		[Bindable] public var calEndDs:BrightDateField;
		
		[Bindable] public var calendarEditorView:CalendarEditorViewLayout; 
		[Bindable] protected var calDescriptor:BrightCalendarDescriptor = new BrightCalendarDescriptor();
		
		private var _displayMode:int = -1;
		private var _displayModeChanged:Boolean = false;
		private var _columnsChanged:Boolean;
		
		private var _dateDiff:Number;
		
		private var _filterTimeout:uint;
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_columnsChanged) {
				_columnsChanged = false;
				if(!Model.instance.administratorVO.getSetting('calendar.visibleColumns')) {
					Model.instance.administratorVO.setSetting('calendar.visibleColumns', Model.instance.applicationVO.config.columns.calendar);
				}
				DatagridController.setDataGridColumns(calendar_dg, Model.instance.administratorVO.getSetting('calendar.visibleColumns'));
				
			}
			
			if(_displayModeChanged) {
				_displayModeChanged = false;
				
				if(displayMode > 0) {
					if(Model.instance.calendarVO.selectedDate == null)
						Model.instance.calendarVO.selectedDate = new Date();
					
					onSelectedMonthChange();
				} else {
					_getEventsForList();
					
				}
			}
		}
		
		protected function calendarview1_creationCompleteHandler(event:FlexEvent):void {
			Model.instance.administratorVO.addEventListener('settingsChanged', _onSettingsChange);
			_columnsChanged = true;
			invalidateProperties();
		}

		protected function showHandler():void {
			for each(var template:Template in Model.instance.templateVO.rawTemplateDefinitions) {
				if(template.templatetype == TemplateVO.CALENDARTEMPLATE) {
					Model.instance.calendarVO.template = template;
					break;
				}
			}
			if(!Model.instance.calendarVO.template)
				Alert.show("No calendar template found", "Create a calendar template");
			
			Model.instance.calendarVO.removeEventListener("ItemChanged", _calendarChangedHandler);
			Model.instance.calendarVO.addEventListener("ItemChanged", _calendarChangedHandler, false, 0, true);
			
			if(Model.instance.administratorVO.administrator.settings 
				&& Model.instance.administratorVO.administrator.settings.hasOwnProperty('calendar') 
				&& Model.instance.administratorVO.administrator.settings.calendar.hasOwnProperty('defaultMode')) {
				var dm:int = parseInt(Model.instance.administratorVO.administrator.settings.calendar.defaultMode);
				displayMode = isNaN(dm) ? 0 : dm;
			} else {
				displayMode = 0;
			}
		}
		
		protected function addEvent():void {
			var ce:nl.bs10.bright.model.objects.CalendarEvent =new nl.bs10.bright.model.objects.CalendarEvent();
			ce.dates = new Array();
			ce.dates.push(new CalendarDateObject());
			Model.instance.calendarVO.currentItem = ce;
		}
		
		protected function editEvent():void {
			if(calendar_dg.selectedItem)
				CommandController.addToQueue(new GetEventCommand(), calendar_dg.selectedItem.calendarId);
		}
		
		protected function editColumns():void {
			SettingsController.getEditColumnsPopup(Model.instance.applicationVO.config.columns.calendar, Model.instance.templateVO.calendarDefinitions,'calendar.visibleColumns');
		}
		
		protected function deleteEvent():void {
			Alert.show('Are you sure you want to delete this / these event(s)?', 'Please Confirm', Alert.YES|Alert.NO, null, _deleteHandler);
		}
		
		protected function onBottomReached(event:Event):void {
			CommandController.addToQueue(new GetEventsForListCommand(), Model.instance.calendarVO.aevents.length, Model.instance.calendarVO.filter, Model.instance.administratorVO.getSetting('calendar.defaultsort'), Model.instance.administratorVO.getSetting('calendar.defaultsortdir'));	
		}
		
		protected function onCalendarClick(event:MouseEvent):void {
	
			var target:* = event.target;
			var safety:uint = 10;
			while(!(target is Calendar) && --safety > 0) { 
				if(target is com.hevery.cal.event.CalendarEvent) {
					CommandController.addToQueue(new GetEventCommand(), target.eventData.calendarId);
					break;
				}
				target = event.target['parent'];
			}
		}
		
		
		protected function onFilterUp(event:KeyboardEvent):void {
			clearTimeout(_filterTimeout);
			_filterTimeout = setTimeout(function():void {
				var fltr:String = (filter_txt.text != '') ? filter_txt.text : null;
				if(calEndDs.selectedDate) {
					Model.instance.calendarVO.filter = {datestart: calStartDs.selectedDate.getTime() / 1000,
														dateend: calEndDs.selectedDate.getTime() / 1000,
														filter: fltr};
					
				} else {
					Model.instance.calendarVO.filter = fltr;
				}
				if(displayMode == 0) {
					_getEventsForList();
				} else {
					CommandController.addToQueue(new GetEventsForCalendarCommand(), Model.instance.calendarVO.filter, Model.instance.administratorVO.getSetting('calendar.defaultsort'), Model.instance.administratorVO.getSetting('calendar.defaultsortdir'));
				}
				
			}, 200);
			
		}
		
		protected function onHeaderRelease(event:DataGridEvent):void {
			Model.instance.administratorVO.callbacks.push(_getEventsForList);
		}
		
		protected function onSelectedMonthChange(event:Event = null):void {
			if(event && event.currentTarget['selectedDate']) {
				Model.instance.calendarVO.selectedDate = event.currentTarget['selectedDate'];
			}
			CommandController.addToQueue(new GetEventsForCalendarCommand(), Model.instance.calendarVO.filter);
		}
		
		protected function onStartDateChange(event:CalendarLayoutChangeEvent):void {
			var d:Date = event.newDate;
			if(d != null) {
				var ts:Number = d.getTime();
				d = new Date();
				d.setTime(ts);
				if(!calEndDs.selectedDate) {
					d.setDate(d.getDate()+7);
					_dateDiff = d.getTime() - ts;
				} else {
					d.setTime(d.getTime() + _dateDiff);
				}
			} 
			calEndDs.selectedDate = d;
			_dateChange();
		}
		
		protected function onStartDateOpen(event:DropdownEvent):void {
			calStartDs.selectedDate = null;
			calEndDs.selectedDate = null;
			_dateChange();
		}
		
		
		protected function onEndDateOpen(event:DropdownEvent):void {
			calEndDs.selectedDate = null;
			_dateChange();
		}
		
		protected function onEndDateChange(event:CalendarLayoutChangeEvent):void {
			// Don't do anything without a startdate
			if(!calStartDs.selectedDate)
				return;
			
			if(calEndDs.selectedDate) {
				_dateDiff = calEndDs.selectedDate.getTime() - calStartDs.selectedDate.getTime();
			}
			_dateChange();
		}
		
		protected function setViewStack(event:Event):void {
			
			displayMode = cal_vs.selectedIndex = cal_tb.selectedIndex;
		}
		
		protected function sortByType(a:Object, b:Object):int {
			return (a.itemType > b.itemType) ? 1 : -1;
		} 
		 
		private function _calendarChangedHandler(event:Event):void {
			if(Model.instance.calendarVO.currentItem) {
				dg_vbox.percentWidth = 25;
				calendarEditorView.percentWidth = 75;
			} else {
				dg_vbox.percentWidth = 100;
				calendarEditorView.percentWidth = 0;
			}		
		}
		
		private function _dateChange():void {
			var fltr:String = (filter_txt.text != '') ? filter_txt.text : null;
			if(calEndDs.selectedDate && calStartDs.selectedDate) {
				/*trace( calStartDs.selectedDate.getTime().toString(),calEndDs.selectedDate.getTime().toString(), calStartDs.selectedDate.toDateString(), calEndDs.selectedDate.toDateString());*/
				Model.instance.calendarVO.filter = {datestart: calStartDs.selectedDate.getTime() / 1000,
													dateend: calEndDs.selectedDate.getTime() / 1000,
												filter: fltr};
				
			} else {
				Model.instance.calendarVO.filter = fltr;
			}
			_getEventsForList();
		}
		
		private function _deleteHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				CommandController.addToQueue(new DeleteEventsCommand(), calendar_dg.selectedItems);
			}
		}
		
		/**
		 * _getEventsForList function
		 *  
		 **/
		private function _getEventsForList():void {
			Model.instance.applicationVO.isLoading = true;
			CommandController.addToQueue(new GetEventsForListCommand(), 0, Model.instance.calendarVO.filter, Model.instance.administratorVO.getSetting('calendar.defaultsort'), Model.instance.administratorVO.getSetting('calendar.defaultsortdir'));
		}
		
		/**
		 * _onSettingsChange function
		 *  
		 **/
		private function _onSettingsChange(event:BrightEvent):void {
			if(event.data == 'calendar.visibleColumns') {
				_columnsChanged = true;
				invalidateProperties();
			}
		}
		
		[Bindable(event="displayModeChanged")]
		public function set displayMode(value:int):void {
			if(value !== _displayMode) {
				_displayMode = value;
				_displayModeChanged = true;
				
				Model.instance.administratorVO.setSetting('calendar.defaultMode', value);
				dispatchEvent(new Event("displayModeChanged"));
				invalidateProperties();
			}
		}
		
		/** 
		 * Getter/Setter methods for the displayMode property
		 **/
		public function get displayMode():int {
			return _displayMode;
		}
	}
}