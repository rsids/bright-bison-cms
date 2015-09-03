package nl.bs10.bright.model.objects
{
	import com.adobe.utils.ArrayUtil;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import nl.bs10.bright.model.Model;
	import nl.bs10.brightlib.objects.Page;
	
	
	[RemoteClass(alias="OUserObject")]
	public dynamic class User extends Page {
		
		private var _activationcode:String
	
		private var _email:String = "";
		private var _password:String = "";
		private var _permissions:Array = new Array();
		private var _activated:Boolean;
		private var _deleted:String;
		private var _usergroupsForDisplay:String;
		
		private var _usergroupsstr:String;
		
		[Bindable][Transient] public var flusergroups:ArrayCollection = new ArrayCollection();
		[Bindable][Transient] public var flregistrationdate:Date = new Date();
		[Bindable][Transient] public var fllastlogin:Date = new Date();
		[Bindable][Transient] public var icon:String = "user";

		public function set registrationdate(value:Number):void {
			flregistrationdate = new Date(value * 1000);
		}
		
		public function get registrationdate():Number {
			return Math.round(flregistrationdate.getTime() / 1000);
		}
		
		public function set lastlogin(value:Number):void {
			this.fllastlogin = new Date(value * 1000);
		}
		
		public function get lastlogin():Number {
			return Math.round(fllastlogin.getTime() / 1000);
		}
		
		public function set usergroups(value:Array):void {
			// Display arr;
			if(value) {
				var darr:Array = new Array();
				for each(var group:Object in Model.instance.userVO.usergroups) {
					if(ArrayUtil.arrayContainsValue(value, group.groupId)) {
						darr.push(group.groupname);
					}
				}		
				usergroupsForDisplay = darr.join(', ');
			} else {
				usergroupsForDisplay = '';
			}
			
			flusergroups = new ArrayCollection(value);
		}
		
		public function get usergroups():Array {
			return (flusergroups) ? flusergroups.source : null;
		}
		
		[Bindable(event="activationcodeChanged")]
		public function set activationcode(value:String):void {
			if(value !== _activationcode) {
				_activationcode = value;
				dispatchEvent(new Event("activationcodeChanged"));
			}
		}
		public function get activationcode():String {
			return _activationcode;
		}
		
		[Bindable(event="emailChanged")]
		public function set email(value:String):void {
			if(value !== _email) {
				_email = value;
				dispatchEvent(new Event("emailChanged"));
			}
		}
		public function get email():String {
			return _email;
		}
		
		[Bindable(event="passwordChanged")]
		public function set password(value:String):void {
			if(value !== _password) {
				_password = value;
				dispatchEvent(new Event("passwordChanged"));
			}
		}
		public function get password():String {
			return _password;
		}
		
		[Transient][Bindable(event="usergroupsForDisplayChanged")]
		public function set usergroupsForDisplay(value:String):void {
			if(value !== _usergroupsForDisplay) {
				_usergroupsForDisplay = value;
				dispatchEvent(new Event("usergroupsForDisplayChanged"));
			}
		}

		public function get usergroupsForDisplay():String {
			return _usergroupsForDisplay;
		}
			
		private var _userId:int;
		
		[Bindable(event="userIdChanged")]
		public function set userId(value:int):void {
			if(value !== _userId) {
				_userId = value;
				dispatchEvent(new Event("userIdChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the userId property
		 **/
		public function get userId():int {
			return _userId;
		}
		
		[Bindable(event="permissionsChanged")]
		public function set permissions(value:Array):void {
			if(value !== _permissions) {
				_permissions = value;
				dispatchEvent(new Event("permissionsChanged"));
			}
		}
		public function get permissions():Array {
			return _permissions;
		}
		
		[Bindable(event="activatedChanged")]
		public function set activated(value:Boolean):void {
			if(value !== _activated) {
				_activated = value;
				dispatchEvent(new Event("activatedChanged"));
			}
		}
		public function get activated():Boolean {
			return _activated;
		}
		
		[Bindable(event="deletedChanged")]
		public function set deleted(value:String):void {
			if(value !== _deleted) {
				_deleted = value;
				icon = (_deleted) ? 'user_delete' : 'user';
				dispatchEvent(new Event("deletedChanged"));
			}
		}
		public function get deleted():String {
			return _deleted;
		}
		
		[Bindable(event="usergroupsstrChanged")]
		public function set usergroupsstr(value:String):void {
			if(value !== _usergroupsstr) {
				_usergroupsstr = value;
				dispatchEvent(new Event("usergroupsstrChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the usergroupsstr property
		 **/
		public function get usergroupsstr():String {
			return _usergroupsstr;
		}
		
		/**
		 * Force the group string to be set, this is used after a csv upload. 
		 * The usergroup string is generated BEFORE the usergroups VO is populated with new values
		 * no way to prevent that...
		 */
		[Transient]
		public function setGroupString():void {
			var a:Array = usergroups;
			usergroups = null;
			usergroups = a;
		}
	}
}