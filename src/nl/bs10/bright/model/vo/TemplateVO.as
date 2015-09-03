package nl.bs10.bright.model.vo {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Template;
	
	public class TemplateVO extends EventDispatcher {
		
		public static const PAGETEMPLATE:int = 0;
		public static const MAILINGTEMPLATE:int = 1;
		public static const LISTTEMPLATE:int = 2;
		public static const CALENDARTEMPLATE:int = 3;
		public static const ELEMENTTEMPLATE:int = 4;
		public static const MARKERTEMPLATE:int = 5;
		public static const USERTEMPLATE:int = 6;
		
		private var _parsers:ArrayCollection;
		private var _selectedTemplate:Template;
		private var _templateDefinitions:ArrayCollection = new ArrayCollection();
		private var _userDefinitions:ArrayCollection;
		
		/**
		 * @var plugins Object An object containing all loaded plugins
		 */		
		public var plugins:Object = new Object();
		
		public const types:ArrayCollection = new ArrayCollection([{type:PAGETEMPLATE, label:'Page'}, 
																	{type:MAILINGTEMPLATE, label:'Mail Template'}, 
																	{type:LISTTEMPLATE, label:'List item'}, 
																	{type:CALENDARTEMPLATE, label:'Calendar event'},
																	{type:ELEMENTTEMPLATE, label:'Element'},
																	{type:USERTEMPLATE, label:'User'},
																	{type:MARKERTEMPLATE, label:'Marker'}]);
		
		[Bindable] public var rawTemplateDefinitions:ArrayCollection = new ArrayCollection();
		[Bindable] public var mailingDefinitions:ArrayCollection = new ArrayCollection();
		[Bindable] public var calendarDefinitions:ArrayCollection = new ArrayCollection();
		[Bindable] public var elementDefinitions:ArrayCollection = new ArrayCollection();
		[Bindable] public var markerDefinitions:ArrayCollection = new ArrayCollection();
		[Bindable] public var templateIcons:ArrayCollection = new ArrayCollection();
		
		
		/**
		 * @var fieldTypes ArrayCollection An array of pluginproperties which can be added to a template 
		 */		
		[Bindable] public var fieldTypes:ArrayCollection = new ArrayCollection();
		
		/**
		 * @var fieldTypes ArrayCollection An array of all pluginproperties
		 */		
		[Bindable] public var pluginProperties:ArrayCollection = new ArrayCollection();

		[Bindable(event="parsersChanged")]
		public function set parsers(value:ArrayCollection):void {
			if(value !== _parsers) {
				_parsers = value;
				dispatchEvent(new Event("parsersChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the parsers property
		 **/
		public function get parsers():ArrayCollection {
			return _parsers;
		}

		[Bindable(event="selectedTemplateChanged")]
		public function set selectedTemplate(value:Template):void {
			if(value !== _selectedTemplate) {
				_selectedTemplate = value;
				dispatchEvent(new Event('selectedTemplateChanged'));
			}
		} 
		
		public function get selectedTemplate():Template {
			return _selectedTemplate;
		}

		[Bindable]
		public function set templateDefinitions(value:ArrayCollection):void {
			var s:Sort = new Sort();
			s.fields = [new SortField('templatename')];
			
			var s2:Sort = new Sort();
			
			if(rawTemplateDefinitions) {
				s2 = rawTemplateDefinitions.sort;
			}
			rawTemplateDefinitions = new ArrayCollection(value.toArray());
			rawTemplateDefinitions.sort = s2;
			rawTemplateDefinitions.refresh();
			
			
			mailingDefinitions = new ArrayCollection(value.toArray());
			mailingDefinitions.filterFunction = _filterMailingDefs;
			mailingDefinitions.sort = s;
			mailingDefinitions.refresh();
			
			calendarDefinitions = new ArrayCollection(value.toArray());
			calendarDefinitions.filterFunction = _filterCalendarDefs;
			calendarDefinitions.sort = s;
			calendarDefinitions.refresh();
			
			var nc:uint = calendarDefinitions.length;
			var arr:Array = [];
			var colors:Array = [0x01689B, 0x71AD2B, 0xEF2926, 0x378C9D];
			while(--nc > -1) {
				arr[Template(calendarDefinitions.getItemAt(nc)).id] = {color: colors[nc%4], name:Template(calendarDefinitions.getItemAt(nc)).templatename};
			}
			Model.instance.calendarVO.setCalendars(arr);
			
			elementDefinitions = new ArrayCollection(value.toArray());
			elementDefinitions.filterFunction = _filterElementDefs;
			elementDefinitions.sort = s;
			elementDefinitions.refresh();
			
			userDefinitions = new ArrayCollection(value.toArray());
			userDefinitions.filterFunction = _filterUserDefs;
			userDefinitions.sort = s;
			userDefinitions.refresh();
			
			markerDefinitions = new ArrayCollection(value.toArray());
			markerDefinitions.filterFunction = _filterMarkerDefs;
			markerDefinitions.sort = s;
			markerDefinitions.refresh();
			
			_templateDefinitions = value;
			_templateDefinitions.filterFunction = _filterDefs;
			_templateDefinitions.sort = s;
			_templateDefinitions.refresh();
			
		} 
		
		
		[Bindable(event="userDefinitionsChanged")]
		public function set userDefinitions(value:ArrayCollection):void {
			if(value !== _userDefinitions) {
				_userDefinitions = value;
				dispatchEvent(new Event("userDefinitionsChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the userDefinitions property
		 **/
		public function get userDefinitions():ArrayCollection {
			return _userDefinitions;
		}
		
		public function get templateDefinitions():ArrayCollection {
			return _templateDefinitions;
		}
		
		private function _filterUserDefs(value:Template):Boolean {
			return (value.templatetype == USERTEMPLATE && value.visible);
		}
		
		private function _filterMarkerDefs(value:Template):Boolean {
			return (value.templatetype == MARKERTEMPLATE && value.visible);
		}
		
		private function _filterDefs(value:Template):Boolean {
			return (value.templatetype == PAGETEMPLATE && value.visible);
		}
		
		private function _filterMailingDefs(value:Template):Boolean {
			return (value.templatetype == MAILINGTEMPLATE && value.visible);
		}
		
		private function _filterCalendarDefs(value:Template):Boolean {
			return (value.templatetype == CALENDARTEMPLATE && value.visible);
		}
		
		private function _filterElementDefs(value:Template):Boolean {
			return (value.templatetype == ELEMENTTEMPLATE && value.visible);
		}
		
	}
}