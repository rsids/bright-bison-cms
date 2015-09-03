package nl.bs10.bright.model.vo {
	import mx.collections.ArrayCollection;
	
	public class SettingsVO {
		
		private var _custom:ArrayCollection;
		private var _customTables:Object = {};
		
		public var visibleColumns:ArrayCollection;

		[Bindable]
		public function get custom():ArrayCollection {
			return _custom;
		}

		public function set custom(value:ArrayCollection):void {
			_custom = value;
		}
		
		
		[Bindable(event="customTablesChanged")]
		public function set customTables(value:Object):void {
			if(value !== _customTables) {
				_customTables = value;
				dispatchEvent(new Event("customTablesChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the customTables property
		 **/
		public function get customTables():Object {
			return _customTables;
		}

	}
}