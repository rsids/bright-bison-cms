package nl.bs10.bright.model.vo {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.core.IFlexDisplayObject;
	
	import nl.bs10.bright.commands.page.SetPageCommand;
	import nl.bs10.brightlib.interfaces.IContentVO;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.objects.Page;
	import nl.fur.vein.controllers.CommandController;
	
	public class PageVO extends MultiLangVO implements IContentVO {
		private var _currentItem:Page;
		private var _apages:ArrayCollection = new ArrayCollection();
		
		/**
		 * The current selected / edited page 
		 */
		[Bindable(event="ItemChanged")] 
		override public function set currentItem(value:IPage):void {
			_currentItem = value as Page;
			dispatchEvent(new Event("ItemChanged"));
		}
		
		override public function get currentItem():IPage {
			return _currentItem;
		}
		
		public function get apages():ArrayCollection {
			return _apages;
		}
		
		[Bindable(event="apagesChanged")]
		public function set apages(value:ArrayCollection):void {
			if(_apages !== value) {
				_apages = value;
				dispatchEvent(new Event("apagesChanged"));
			}
		}
		
		/**
		 * An index-based array of pages 
		 */		
		[Bindable] public var pages:Array = new Array();

		[Bindable] public var filterTemplateIds:Array = new Array();
		
		[Bindable] public var filterPageIds:Array;
		
		[Bindable] public var filtertype:String = "AND";
		
		[Bindable] public var filterView:IFlexDisplayObject;
		
		private var _pagesChanged:Boolean = false;
	
		public function set pagesChanged(value:Boolean):void {
			_pagesChanged = value;
			var arr:Array = new Array();
			for each(var co:Page in pages) {
				arr.push(co);
			}
			var s:Sort = apages.sort;
			apages = new ArrayCollection(arr);
			apages.filterFunction = _filter;
			apages.sort = s;
			apages.refresh();
		} 
		
		public function get pagesChanged():Boolean {
			return _pagesChanged;
		}
		
		private function _filter(page:Page):Boolean {
			var btemplate:Boolean = (filterTemplateIds[page.itemType]); 
			var bpage:Boolean = (filterPageIds && filterPageIds[page.pageId]);
			if(!filterPageIds)
				bpage = true;
				
			if(filtertype == "OR")
				return btemplate || bpage;
				
			return btemplate && bpage;
		}
		
		override public function save(callback:Function):void {
			CommandController.addToQueue(new SetPageCommand(), currentItem, callback);
		}
	}
}