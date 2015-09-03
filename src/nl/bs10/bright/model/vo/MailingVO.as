package nl.bs10.bright.model.vo {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FullScreenEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import nl.bs10.bright.commands.mailing.SetMailingCommand;
	import nl.bs10.brightlib.interfaces.IContentVO;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.Page;
	import nl.bs10.brightlib.objects.Template;
	import nl.fur.vein.controllers.CommandController;
	
	public class MailingVO extends EventDispatcher implements IContentVO {
		
		private var _currentItem:IPage;
		private var _currentDefinition:Template;
		private var _amailings:ArrayCollection = new ArrayCollection();
		private var _template:Template;
		private var _tabs:ArrayCollection = new ArrayCollection();
		private var _locked:Boolean;
		
		public var mailings:Array = new Array();
		
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

		public function get amailings():ArrayCollection {
			return _amailings;
		}
		
		[Bindable(event="amailingsChanged")]
		public function set amailings(value:ArrayCollection):void {
			if(_amailings !== value) {
				_amailings = value;
				dispatchEvent(new Event("amailingsChanged"));
			}
		}

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

		[Bindable(event="ItemChanged")] 
		public function set currentItem(value:IPage):void {
			if(_currentItem !== value) {
				_currentItem = value;
				dispatchEvent(new Event("ItemChanged"));
			}
		}
		
		public function get currentItem():IPage {
			return _currentItem;
		}
		
		public function save(callback:Function):void {
			CommandController.addToQueue(new SetMailingCommand(), currentItem, callback);
		}
		
		public function updateMailings():void {
			var s:Sort;
			if(amailings) 
				s = amailings.sort;
			
			var ta:Array = new Array;
			for each(var item:Page in mailings){
				ta.push(item);
			}
			
			amailings = new ArrayCollection(ta);
			amailings.sort = s;
			amailings.refresh();
		}
	}
}