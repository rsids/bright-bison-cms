package nl.bs10.bright.views.structure {
	
	import com.adobe.utils.ArrayUtil;
	
	import flash.events.Event;
	
	import mx.containers.Panel;
	import mx.controls.List;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.tree.GetAccessCommand;
	import nl.bs10.bright.commands.tree.SetAccessCommand;
	import nl.bs10.bright.commands.users.GetUserGroupsCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.controllers.CommandController;

	public class ChooseUserGroupView extends Panel{
		
		private var _viewId:String;
		private var _treeId:int;
		private var _treeIdChanged:Boolean;
		private var _usergroupsChanged:Boolean;
		
		private var _groups:Array;
		private var _groupsChanged:Boolean;
		
		[Bindable] public var ug_lst:List;
		
		protected function getUserGroups():void {
			if(!Model.instance.userVO.usergroups || Model.instance.userVO.usergroups.length == 0) {
				Model.instance.userVO.addEventListener("usergroupsChanged", _onUsergroupsChanged, false, 0, true);
				CommandController.addToQueue(new GetUserGroupsCommand());
			} else {
				_usergroupsChanged = true;
				invalidateProperties();
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_treeIdChanged) {
				_treeIdChanged = false;
				CommandController.addToQueue(new GetAccessCommand(), treeId, _onGetGroups);
			}
			
			if(_groupsChanged && Model.instance.userVO.usergroups) {
				_groupsChanged  = false;
				if(_groups && _groups.length > 0) {
					var si:Array = [];
					for each(var group:Object in Model.instance.userVO.usergroups) {
						if(ArrayUtil.arrayContainsValue(_groups,group.groupId.toString())) {
							si.push(group);
						}
					}
					ug_lst.selectedItems = si;
				}
			}
		}
		
		protected function close():void {
			Model.instance.userVO.removeEventListener("usergroupsChanged", _onUsergroupsChanged, false);
			PopUpManager.removePopUp(this);
		}
		
		protected function save():void {
			var grps:Array = new Array();
			for each(var group:Object in ug_lst.selectedItems) {
				grps.push(group.groupId);
			}
			CommandController.addToQueue(new SetAccessCommand(), _treeId, grps, close);
			
		}
		
		public function get groups():Array {
			return _groups;
		}
		
		[Bindable(event="groupsChanged")]
		public function set groups(val:Array):void	{
			if(_groups != val) {
				_groups = val;
				_groupsChanged = true;
				invalidateProperties();
			}
			dispatchEvent(new Event('groupsChanged'));
		}
		
		public function get treeId():int {
			return _treeId;
		}
		
		[Bindable(event="treeIdChanged")]
		public function set treeId(val:int):void	{
			if(_treeId != val) {
				_treeId = val;
				_treeIdChanged = true;
				invalidateProperties();
				
			}
			dispatchEvent(new Event('treeIdChanged'));
		}
		
		private function _onGetGroups($groups:Array):void {
			groups = $groups;
		}
		
		private function _onUsergroupsChanged(event:Event):void {
			_usergroupsChanged = true;
			invalidateProperties();
		}
	}
}