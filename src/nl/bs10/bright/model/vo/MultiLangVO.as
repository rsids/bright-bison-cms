package nl.bs10.bright.model.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import nl.bs10.brightlib.interfaces.IContentVO;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.Template;

	public class MultiLangVO extends EventDispatcher implements IContentVO {
		private var _tabs:ArrayCollection = new ArrayCollection();
		private var _locked:Boolean;
		private var _template:Template;
		private var _currentDefinition:Template;
		
		public function get locked():Boolean {
			return _locked;
		}
		
		[Bindable(event="lockedChanged")]
		public function set locked(value:Boolean):void {
			if(_locked !== value) {
				_locked = value;
				dispatchEvent(new Event("lockedChanged"));
			}
		}
		
		/**
		 * Stub 
		 * @param value
		 * 
		 */
		public function set currentItem(value:IPage):void {
		}
		
		public function get currentItem():IPage {
			return null
		}
		
		/**
		 * The definition of currentItem 
		 */
		public function get currentDefinition():Template {
			return _currentDefinition;
		}
		
		[Bindable(event="currentDefinitionChanged")]
		public function set currentDefinition(value:Template):void {
			if(_currentDefinition !== value) {
				_currentDefinition = value;
				dispatchEvent(new Event("currentDefinitionChanged"));
			}
		}
		
		public function get tabs():ArrayCollection {
			return _tabs;
		}
		
		[Bindable(event="tabsChanged")]
		public function set tabs(value:ArrayCollection):void {
			if(_tabs !== value) {
				_tabs = value;
				dispatchEvent(new Event("tabsChanged"));
			}
		}
		
		public function get template():Template {
			return _template;
		}
		
		[Bindable(event="templateChanged")]
		public function set template(value:Template):void {
			if(_template !== value) {
				_template = value;
				dispatchEvent(new Event("templateChanged"));
			}
		}
		
		public function save(callback:Function):void {
			// Stub
		}

	}
}