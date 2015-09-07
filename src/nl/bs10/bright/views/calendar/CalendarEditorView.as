package nl.bs10.bright.views.calendar {
	import com.adobe.utils.StringUtil;
	
	import flash.events.Event;
	
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.DateField;
	import mx.controls.NumericStepper;
	import mx.controls.RadioButtonGroup;
	import mx.controls.TextInput;
	import mx.core.Repeater;
	import mx.events.FlexEvent;
	import mx.formatters.DateFormatter;
	
	import nl.bs10.bright.components.CalendarDateRenderer;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.objects.CalendarDateObject;
	import nl.bs10.bright.model.objects.CalendarEvent;
	import nl.bs10.bright.views.content.ItemEditorView;
	import nl.bs10.brightlib.components.BrightDateField;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.flexperiments.time.FlpDateManager;
	import nl.fur.vein.events.VeinDispatcher;
	import nl.fur.vein.events.VeinEvent;

	public class CalendarEditorView extends ItemEditorView {
		
		private var _overview:String;
		private var _updateOverview:Boolean;
		private var _eventChanged:Boolean;
		private var _markersChanged:Boolean;
		
		[Bindable] public var enabled_chb:CheckBox;
		[Bindable] public var repeat_chb:CheckBox;
		[Bindable] public var allday_chb:CheckBox;
		[Bindable] public var sun_chb:CheckBox;
		[Bindable] public var mon_chb:CheckBox;
		[Bindable] public var tue_chb:CheckBox;
		[Bindable] public var wed_chb:CheckBox;
		[Bindable] public var thu_chb:CheckBox;
		[Bindable] public var fri_chb:CheckBox;
		[Bindable] public var sat_chb:CheckBox;
		
		[Bindable] public var repeat_cmb:ComboBox;
		[Bindable] public var location_cmb:ComboBox;
		
		[Bindable] public var endrepeat_df:BrightDateField;
		
		[Bindable] public var interval_ns:NumericStepper;
		
		[Bindable] public var repeatmonth_rbg:RadioButtonGroup;
		[Bindable] public var dates_vb:VBox;
		
		public function CalendarEditorView() {
			Model.instance.calendarVO.addEventListener("eventChanged", _eventChangedHandler);
			VeinDispatcher.instance.addEventListener('markersUpdate', _onMarkersUpdate);
		}
		
		override protected function save(callcancel:Boolean=true, error:Array = null):void {
			var recur:String = "";
			error = new Array();
			
			
			var caldates:Array = dates_vb.getChildren();
			var newdates:Array = new Array();
			for each(var caldate:CalendarDateRenderer in caldates) {
				var result:* = caldate.dates;
				if(result is String) {
					error.push(result)
				} else {
					newdates.push(result);
				}
			}
			// Stop processing, has no use..
			if(error.length == 0) {
				
				CalendarEvent(contentVO.currentItem).locationId = (location_cmb.selectedItem) ? location_cmb.selectedItem.pageId : null;
				CalendarEvent(contentVO.currentItem).dates = newdates;
				if(newdates.length == 1 && repeat_chb.selected) {
					
					recur = "FREQ=";
					
					if(repeat_cmb.selectedItem) {
						recur += repeat_cmb.selectedItem.data.toString() + ";";
						
						
						if(endrepeat_df.selectedDate) {
                            endrepeat_df.selectedDate.setHours(23);
                            endrepeat_df.selectedDate.setMinutes(59);
                            endrepeat_df.selectedDate.setSeconds(59);
							var df:DateFormatter = new DateFormatter();
							df.formatString ='YYYYMMDDTJNNSSZ'; 
									//Ymd\THis';
							recur += "UNTIL=" + df.format(endrepeat_df.selectedDate) + ";";
							CalendarEvent(contentVO.currentItem).until = endrepeat_df.selectedDate.getTime() / 1000;
						} else {
							// ERROR
							error.push("You have to select an end date for the repeat");
						}
						
						
						recur += "INTERVAL=" + interval_ns.value + ";";
						switch(repeat_cmb.selectedIndex) {
							case 1:
								// weeks
								var arr:Array = [sun_chb, mon_chb, tue_chb, wed_chb, thu_chb, fri_chb, sat_chb];
								var seldays:Array = new Array();
								var i:int = 0;
								for each(var day:CheckBox in arr) {
									if(day.selected)
										seldays.push(FlpDateManager.getDayNames()[i].substr(0,2).toUpperCase());
									i++;
								}
								
								if(seldays.length > 0) {
									recur += "BYDAY=" + seldays.join(",") + ";";
								} else {
									// ERROR!
									error.push("Please select at least one weekday");
								}
									
								break;
							case 2:
								// month
								recur += "BYMONTH=" + (newdates[0].flstarttime.month + 1).toString() + ";";
								
								if(repeatmonth_rbg.selectedValue == "dow") {
									var d:int = newdates[0].flstarttime.day;
									var nd:int = Math.ceil(newdates[0].flstarttime.date / 7);
									recur += "BYDAY=+" + nd + " " + FlpDateManager.parseDate(newdates[0].flstarttime, "D").substr(0,2).toUpperCase() + ";";
								} else {
									recur += "BYMONTHDAY=" + newdates[0].flstarttime.date + ";";
								}
								break;
							case 3: 
								// year
								recur += "BYMONTH=" + (newdates[0].flstarttime.month + 1).toString() + ";";
								recur += "BYMONTHDAY=" + newdates[0].flstarttime.date + ";";
								break;
						}
					} else {
						// ERROR!
						error.push("Please choose a repeat interval");
					}
				}
				
				CalendarEvent(contentVO.currentItem).enabled = enabled_chb.selected;
				CalendarEvent(contentVO.currentItem).recur = recur;
					
				if(newdates.length ==0) {
					error.push("You must set at least 1 date");
					
				} else if(!newdates[0].flstarttime || !newdates[0].flendtime) {
					error.push("You must set at least 1 date");
					 
				} else if(newdates[0].flstarttime.getTime() > newdates[0].flendtime.getTime()) {
					error.push("The start date must be before the end date");
				}
			}
			super.save(callcancel, error);			
		}
		
		protected function updateOverview(event:Event = null):void {
			if(!contentVO.currentItem)
				return;
			
			var nc:uint = dates_vb.numChildren;
			if(event) {
				if(event.type == 'childRemove')
					nc--;
				
				if(event.type == 'datesChanged') {
					CalendarEvent(contentVO.currentItem).dates[0] = CalendarDateRenderer(dates_vb.getChildAt(0)).dates;
				}
			}
		 	if(nc > 1) {
				CalendarEvent(contentVO.currentItem).recur = "";
				repeat_chb.visible = false;
				repeat_chb.selected = false;
			} else {
				repeat_chb.visible = true;
				_updateOverview = true;
			}
			
			invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_eventChanged) {
				_eventChanged = false;
				
				if(!Model.instance.calendarVO.currentEvent)
					return;
				
				dates_vb.removeAllChildren();
				for each(var doa:CalendarDateObject in CalendarEvent(contentVO.currentItem).dates) {
					var cdr:CalendarDateRenderer = new CalendarDateRenderer();
					dates_vb.addChild(cdr);
					cdr.addEventListener('datesChanged', updateOverview, false, 0, true);
					cdr.dates = doa;
				}
				
				var recurarr:Array;
				if(Model.instance.calendarVO.currentEvent.recur)
					recurarr = Model.instance.calendarVO.currentEvent.recur.split(";");
				
				if(recurarr && recurarr.length > 0) {
					// Recurrence
					var freq:String;
				
					for each(var rrule:String in recurarr) {
					
						if(rrule != '') {
							//FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR;
							var rulearr:Array = rrule.split("=");
						
							switch(rulearr[0]) {
								case 'FREQ':
									freq = rulearr[1];
									for each(var repeatoption:Object in Model.instance.calendarVO.repeatoptions) {
										if (repeatoption.data == rulearr[1]) {
											repeat_cmb.selectedItem = repeatoption;
											break;
										}
									}
									
									break;
								
								case 'UNTIL':
									//CalendarEvent(contentVO.currentItem).fluntil = new Date(rulearr[1]);
									/* endrepeat_df.selectedDate = new Date(rulearr[1]); */
									break;
								
								case 'INTERVAL':
									interval_ns.value = Number(rulearr[1]);
									break;
								
								case 'BYDAY':
									// Differrence between monthly and weekly
									switch(freq){
										case 'WEEKLY':
											var dayarr:Array = rulearr[1].split(",");
											
											mon_chb.selected = false;
											tue_chb.selected = false;
											wed_chb.selected = false;
											thu_chb.selected = false;
											fri_chb.selected = false;
											sat_chb.selected = false;
											sun_chb.selected = false;
											
											for each(var daystr:String in dayarr) {
												switch(daystr) {
													case 'MO': mon_chb.selected = true; break;
													case 'TU': tue_chb.selected = true; break;
													case 'WE': wed_chb.selected = true; break;
													case 'TH': thu_chb.selected = true; break;
													case 'FR': fri_chb.selected = true; break;
													case 'SA': sat_chb.selected = true; break;
													case 'SU': sun_chb.selected = true; break;
												}
											}
											break;
										case 'MONTHLY':
											repeatmonth_rbg.selectedValue = 'dow';
											break;
									}
									break;
								
								case 'BYMONTHDAY':
									// Differrence between monthly and yearly
									switch(freq){
										case 'MONTHLY':
											repeatmonth_rbg.selectedValue = 'dom';
											break;
									}
									
									break;
							}
						}
					}
				}
				_markersChanged = true;
				_updateOverview = true;
			}
			
			if(_markersChanged) {
				if( Model.instance.mapsVO.items) {
					_markersChanged = false;
					location_cmb.selectedItem = null;
					if(!isNaN(CalendarEvent(contentVO.currentItem).locationId) &&CalendarEvent(contentVO.currentItem).locationId > 0) {
						var nc:int = Model.instance.mapsVO.items.length;
						while(--nc > -1) {
							if(Model.instance.mapsVO.items.getItemAt(nc).pageId == CalendarEvent(contentVO.currentItem).locationId) {
								location_cmb.selectedItem = Model.instance.mapsVO.items.getItemAt(nc);
								nc = -1;
							}
						}
					}
				}
			}
			if(_updateOverview) {
				_updateOverview = false;
				
				if(!repeat_chb.selected || repeat_cmb.selectedIndex == -1) {
					overview = "";
				} else {
					var ov:String = "Every ";
					if(interval_ns.value > 1) {
						ov += interval_ns.value.toString() + " " + repeat_cmb.selectedItem.label.toLowerCase() + "s ";
					} else {
						ov += repeat_cmb.selectedItem.label.toLowerCase() + " ";
						
					}
					var dateObj:CalendarDateObject = CalendarEvent(contentVO.currentItem).dates[0];
					if(dateObj.flstarttime) {
						switch(repeat_cmb.selectedIndex) {
							case 1:
								// weeks
								var arr:Array = [sun_chb, mon_chb, tue_chb, wed_chb, thu_chb, fri_chb, sat_chb];
								var seldays:Array = new Array();
								var i:int = 0;
								for each(var day:CheckBox in arr) {
									if(day.selected)
										seldays.push(FlpDateManager.getDayNames()[i]);
									i++;
								}
								if(seldays.length > 0)
									ov += " on " + seldays.join(", ");
									
								break;
							case 2:
								// month
								if(repeatmonth_rbg.selectedValue == "dow") {
									var d:int = dateObj.flstarttime.day;
									var nd:int = Math.ceil(dateObj.flstarttime.date / 7);
									ov += "on the " + nd + _getSuffix(nd) + " " + FlpDateManager.parseDate(dateObj.flstarttime, "l");
								} else {
									ov += "on the " + dateObj.flstarttime.date + _getSuffix(dateObj.flstarttime.date);
								}
								break;
							case 3: 
								// year
								ov += "on the " + dateObj.flstarttime.date + _getSuffix(dateObj.flstarttime.date) + " of " + FlpDateManager.parseDate(dateObj.flstarttime, "F");
								break;
						}
						if(endrepeat_df.selectedDate)
							ov += " until " + FlpDateManager.parseDate(endrepeat_df.selectedDate, "d-m-Y");
						overview = ov;
					}
				}
			}
			
			
		}
		
		protected function onShow():void {
			VeinDispatcher.instance.dispatch('requestMarkerUpdate', null);
		}
		
		protected function searchLocation():void {
			VeinDispatcher.instance.dispatch("requestPopup", {callback: _onSelectLocation, popup:'markerlist'});
		}
		
		
		private function _eventChangedHandler(event:Event):void {
			_eventChanged = true;
			invalidateProperties();
		}
		
		private function _getSuffix(value:int):String {
			var suffix:String = 'th';
			if(!(value >= 10 && value < 20)) {
				var s:Array = ['st','nd','rd'];
				var sa:String = s[value % 10 - 1];
				suffix = sa ? sa : 'th';
			}
			return  suffix;
		}
		
		/**
		 * _onMarkersUpdate function
		 *  
		 **/
		private function _onMarkersUpdate(event:VeinEvent):void {
			if(Model.instance.calendarVO.currentEvent) {
				_markersChanged = true;
				invalidateProperties();
			}
		}
		
		
		/**
		 * _onSelectLocation function
		 * Callback from the popup
		 *  
		 **/
		private function _onSelectLocation(data:IPage):void {
			CalendarEvent(contentVO.currentItem).locationId = data.pageId;
			_markersChanged = true;
			invalidateProperties();
		}
		
		[Bindable(event="overviewChanged")]
		public function set overview(value:String):void {
			if(_overview !== value) {
				_overview = value;
				dispatchEvent(new Event("overviewChanged"));
			}
		}
		public function get overview():String {
			return _overview;
		}
	}
	
}
