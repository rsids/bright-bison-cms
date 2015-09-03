package nl.bs10.bright.model.vo {
	
	import com.adobe.utils.ArrayUtil;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	
	import nl.bs10.bright.commands.users.SetUserCommand;
	import nl.bs10.bright.model.objects.User;
	import nl.bs10.brightlib.interfaces.IContentVO;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.fur.vein.controllers.CommandController;
	
	public class UserVO extends MultiLangVO implements IContentVO {

		private var _currentItem:IPage;
		private var _currentUser:User;
		private var _showDeleted:Boolean;
		private var _usergroups:ArrayCollection;
		private var _ausers:ArrayCollection = new ArrayCollection();
				
		[Bindable] public var unusedGroups:ArrayCollection = new ArrayCollection();
		
		[Bindable] public var users:Array = new Array();

		public var usersFetched:Boolean = false;
		
		private var _usersChanged:Boolean = false;
	
		public function set usersChanged(value:Boolean):void {
			_usersChanged = value;
			var arr:Array = new Array();
			for each(var co:User in users) {
				arr.push(co);
			}
			var s:Sort = ausers.sort;
			
			ausers = new ArrayCollection(arr);
			ausers.sort = s;
			if(!showDeleted)
				ausers.filterFunction = _deletedFilter;
			ausers.refresh();
		} 
		
		public function get usersChanged():Boolean {
			return _usersChanged;
		}
		
		[Bindable(event="ausersChanged")]
		public function set ausers(value:ArrayCollection):void {
			if(_ausers !== value) {
				_ausers = value;
					
				dispatchEvent(new Event("ausersChanged"));
			}
		}
		
		public function get ausers():ArrayCollection {
			return _ausers;
		}
 
		[Bindable(event="ItemChanged")] 
		override public function set currentItem(value:IPage):void {
			super.currentItem = value;
			if(value !== _currentItem) {
				_currentItem = value;
				currentUser = value as User;
				dispatchEvent(new Event("ItemChanged"));
			}
		}
		
		override public function get currentItem():IPage {
			return _currentItem;
		}
		
		public function get currentUser():User {
			return _currentUser;
		}
		
		[Bindable(event="currentUserChanged")] 
		public function set currentUser(value:User):void {
			if(_currentUser != value) {
				_currentUser = value;
				dispatchEvent(new Event('currentUserChanged'));
			}
		}
		
		[Bindable(event="showDeletedChanged")]
		public function set showDeleted(value:Boolean):void {
			if(value !== _showDeleted) {
				_showDeleted = value;
				if(_showDeleted) {
					ausers.filterFunction = null;
				} else {
					ausers.filterFunction = _deletedFilter;
				}
				ausers.refresh();
				dispatchEvent(new Event("showDeletedChanged"));
			}
		}
		public function get showDeleted():Boolean {
			return _showDeleted;
		}
		
		private function _deletedFilter(value:User):Boolean {
			return value.deleted == null;
		}
		
		[Bindable(event="usergroupsChanged")]
		public function set usergroups(value:ArrayCollection):void {
			if(value !== _usergroups) {
				_usergroups = value;
				dispatchEvent(new Event("usergroupsChanged"));
			}
		}
		public function get usergroups():ArrayCollection {
			return _usergroups;
		}
		
		override public function save(callback:Function):void {
			CommandController.addToQueue(new SetUserCommand(), currentItem, callback);
		}
	}
}