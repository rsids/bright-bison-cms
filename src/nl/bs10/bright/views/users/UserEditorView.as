package nl.bs10.bright.views.users {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.CheckBox;
	import mx.controls.TextInput;
	import mx.events.ValidationResultEvent;
	import mx.validators.Validator;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.vo.TemplateVO;
	import nl.bs10.bright.views.content.ItemEditorView;
	import nl.bs10.brightlib.components.LabeledInput;
	import nl.bs10.brightlib.controllers.ValidatorController;
	import nl.bs10.brightlib.objects.Template;
	import nl.bs10.brightlib.utils.Formatter;

	public class UserEditorView extends ItemEditorView {
		
		[Bindable] public var userlabel_txt:LabeledInput;
		[Bindable] public var email_txt:LabeledInput;
		[Bindable] public var password_txt:LabeledInput;
		[Bindable] public var activated_chb:CheckBox;
		[Bindable] public var deleted_chb:CheckBox;
		[Bindable] public var ug_vbox1:VBox;
		[Bindable] public var ug_vbox2:VBox;
		[Bindable] public var ug_hbox:HBox;
		
		private var _userChanged:Boolean;
		private var _usergroupsChanged:Boolean;
		private var _validators:Array;
		
		public function UserEditorView() {
			super(false);
		}
		
		override protected function save(callcancel:Boolean=true, error:Array=null):void {
			var valresult:Array = Validator.validateAll(_validators);
			if(valresult.length == 0) {
				// Valid;
				Model.instance.userVO.currentUser.label = userlabel_txt.text;
				Model.instance.userVO.currentUser.email = email_txt.text;
				Model.instance.userVO.currentUser.password = password_txt.text;
				Model.instance.userVO.currentUser.deleted = (deleted_chb.selected) ? Formatter.realFormatDate(new Date(), 'YYYY-MM-DD J:NN') : null;
				Model.instance.userVO.currentUser.activated = activated_chb.selected;
				
			} else {
				
				var errString:String = "Cannot save user, reason(s):\n";
				
				for each(var valres:ValidationResultEvent in valresult) {
					errString += valres.message + "\n";	
				}	
				
				error = [errString];
			}
			super.save(callcancel, error);
			
		}
		
		
		override protected function createChildren():void {
			super.createChildren();
			
			Model.instance.userVO.addEventListener('currentUserChanged', _onCurrentUserChange, false, 0, true);
			Model.instance.userVO.addEventListener('usergroupsChanged', _onUsergroupsChange, false, 0, true);
			if(Model.instance.userVO.currentUser != null)
				_userChanged = true;
			
			label_txt = new TextInput();
		}
		
		
		override protected function commitProperties():void {
			if(_userChanged) {
				_userChanged = false;
				_usergroupsChanged = true;
				
				if(!Model.instance.templateVO.userDefinitions || Model.instance.templateVO.userDefinitions.length == 0) {
					Model.instance.userVO.tabs = new ArrayCollection();
					Model.instance.userVO.tabs.removeAll();
					Model.instance.userVO.tabs.addItem({label:"Settings", value: "settings", icon:Model.instance.applicationVO.langimages.settings});
					
					var tpl:Template = new Template();
					tpl.templatetype = TemplateVO.USERTEMPLATE;
					types_cmb.dataProvider = [tpl];
					types_cmb.visible = false;
				}
				
				_validators = new Array();
				_validators.push(ValidatorController.createEmailValidator(email_txt, "text", true));
			}
			
			if(_usergroupsChanged) {
				
				_usergroupsChanged = false;
				var sa:CheckBox = ug_vbox1.removeChildAt(ug_vbox1.numChildren-1) as CheckBox;
				var nc1:int = ug_vbox1.numChildren-1;
				var nc2:int = ug_vbox2.numChildren-1;
				
				// Clean up old checkboxes
				var chb:CheckBox;
				while(--nc1 > -1) {
					chb = ug_vbox1.removeChildAt(nc1) as CheckBox;
					chb.removeEventListener(Event.CHANGE, _onSelectGroup);
					chb = null;
				}
				while(--nc2 > -1) {
					chb = ug_vbox2.removeChildAt(nc2) as CheckBox;
					chb.removeEventListener(Event.CHANGE, _onSelectGroup);
					chb = null;
				}
				
				if(Model.instance.userVO.currentUser) {
					var groups:ArrayCollection = Model.instance.userVO.usergroups;
					var ugroups:ArrayCollection = Model.instance.userVO.currentUser.flusergroups;
					var ng:int = Math.floor(groups.length / 2);
					var i:int = 0;
					var box:VBox = ug_vbox1;
					for each(var group:Object in groups) {
						chb = new CheckBox();
						chb.label = group.groupname;
						chb.data = group.groupId;
						chb.addEventListener(Event.CHANGE, _onSelectGroup, false,0,true);
						chb.selected = ugroups.contains(group.groupId);
						box.addChild(chb);
						if(i++ == ng) {
							box = ug_vbox2;
						}
					}
				}
				ug_vbox1.addChild(sa);
			}
			super.commitProperties();
		}
		
		protected function onSelectAll(evt:Event):void {
			var nc:int = ug_vbox1.numChildren;
			var groups:Array = [];
			Model.instance.userVO.currentUser.usergroups = [];
			while(--nc > -1) {
				if(ug_vbox1.getChildAt(nc) != evt.currentTarget) {
					ug_vbox1.getChildAt(nc)['selected'] = evt.currentTarget.selected;
					groups.push(ug_vbox1.getChildAt(nc)['data']);
				}
			}
			nc = ug_vbox2.numChildren;
			while(--nc > -1) {
				ug_vbox2.getChildAt(nc)['selected'] = evt.currentTarget.selected;
				groups.push(ug_vbox2.getChildAt(nc)['data']);
			}
			if(evt.currentTarget.selected) {
				Model.instance.userVO.currentUser.usergroups = groups;
			}
			
		}
		
		private function _onCurrentUserChange(e:Event):void {
			_userChanged = true; 
			invalidateProperties();
		}
		
		private function _onSelectGroup(event:Event):void {
			if(event.currentTarget.selected) {
				Model.instance.userVO.currentUser.flusergroups.addItem(event.currentTarget.data);
			} else {
				var nc:int = Model.instance.userVO.currentUser.flusergroups.length;
				while(--nc > -1) {
					if(Model.instance.userVO.currentUser.flusergroups.getItemAt(nc) == event.currentTarget.data) {
						Model.instance.userVO.currentUser.flusergroups.removeItemAt(nc);
					}
				}
			}
		}
		
		private function _onUsergroupsChange(e:Event):void {
			_usergroupsChanged = true;
			invalidateProperties();
		}
		
	}
	
}
