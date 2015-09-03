package nl.bs10.bright.controllers {
	public class PermissionController {

		public static const IS_AUTH:String = "IS_AUTH:String";
		public static const MANAGE_ADMIN:String = "MANAGE_ADMIN";
		public static const CREATE_PAGE:String = "CREATE_PAGE";
		public static const DELETE_PAGE:String = "DELETE_PAGE";
		public static const EDIT_PAGE:String = "EDIT_PAGE";
		public static const MOVE_PAGE:String = "MOVE_PAGE";
		public static const UPLOAD_FILE:String = "UPLOAD_FILE";
		public static const DELETE_FILE:String = "DELETE_FILE";
		public static const MANAGE_TEMPLATE:String = "MANAGE_TEMPLATE";
		public static const MANAGE_SETTINGS:String = "MANAGE_SETTINGS";
		public static const MANAGE_USER:String = "MANAGE_USER";
		public static const MANAGE_MAILINGS:String = "MANAGE_MAILINGS";
		public static const MANAGE_CALENDARS:String = "MANAGE_CALENDARS";
		public static const MANAGE_ELEMENTS:String = "MANAGE_ELEMENTS";
		public static const MANAGE_MAPS:String = "MANAGE_MAPS";

		[Bindable] public var _IS_AUTH:Boolean = false;
		[Bindable] public var _MANAGE_ADMIN:Boolean = false;
		[Bindable] public var _CREATE_PAGE:Boolean = false;
		[Bindable] public var _DELETE_PAGE:Boolean = false;
		[Bindable] public var _EDIT_PAGE:Boolean = false;
		[Bindable] public var _MOVE_PAGE:Boolean = false;
		[Bindable] public var _UPLOAD_FILE:Boolean = false;
		[Bindable] public var _DELETE_FILE:Boolean = false;
		[Bindable] public var _MANAGE_TEMPLATE:Boolean = false;
		[Bindable] public var _MANAGE_SETTINGS:Boolean = false;
		[Bindable] public var _MANAGE_USER:Boolean = false;
		[Bindable] public var _MANAGE_MAILINGS:Boolean = false;
		[Bindable] public var _MANAGE_CALENDARS:Boolean = false;
		[Bindable] public var _MANAGE_ELEMENTS:Boolean = false;
		[Bindable] public var _MANAGE_MAPS:Boolean = false;
		
		private static var _instance:PermissionController;
		
		[Bindable]
		public var permissions:Array = [{permission:"IS_AUTH", label:"Authenticated"},
										{permission:"MANAGE_ADMIN", label:"Edit Administrators"},
										{permission:"CREATE_PAGE", label:"Create pages"},
										{permission:"DELETE_PAGE", label:"Delete pages"},
										{permission:"EDIT_PAGE", label:"Edit pages"},
										{permission:"MOVE_PAGE", label:"Move pages"},
										{permission:"UPLOAD_FILE", label:"Upload files"},
										{permission:"DELETE_FILE", label:"Delete files"},
										{permission:"MANAGE_USER", label:"Manage users (front end users)"},
										{permission:"MANAGE_SETTINGS", label:"Manage custom settings"},
										{permission:"MANAGE_TEMPLATE", label:"Manage templates"},
										{permission:"MANAGE_CALENDARS", label:"Manage calendars"},
										{permission:"MANAGE_ELEMENTS", label:"Manage page elements"},
										{permission:"MANAGE_MAILINGS", label:"Create and send mailings"},
										{permission:"MANAGE_MAPS", label:"Create and edit maps"}];
		
		public function PermissionController(s:SingletonEnforcer) {			
			if(!s)
				throw new Error("You cannot create instances of this class, it's a singleton!");
		}
		
		public static function get instance():PermissionController {
			if(!_instance) _instance = new PermissionController(new SingletonEnforcer());
			return _instance;
		}
		
		/**
		 * Set the permissions of a user 
		 * @param value An array with permissions
		 * 
		 */		
		public function setPermissions(value:Array):void {
			_IS_AUTH = false;
			_MANAGE_USER = false;
			_MANAGE_ADMIN = false;
			_CREATE_PAGE = false;
			_DELETE_PAGE = false;
			_EDIT_PAGE = false;
			_MOVE_PAGE = false;
			_UPLOAD_FILE = false;
			_DELETE_FILE = false;
			_MANAGE_TEMPLATE = false;
			_MANAGE_SETTINGS = false;
			_MANAGE_MAILINGS = false;
			_MANAGE_CALENDARS = false;
			_MANAGE_ELEMENTS = false;
			_MANAGE_MAPS = false;
			
			for each(var permission:String in value) {
				if(hasOwnProperty("_" + permission)) {
					this["_" + permission] = true;
				}
			}
		}
		
		/**
		 * Sets a single permission 
		 * @param perm The permission to set
		 * @param value The new value
		 */		
		public function setPermission(perm:String, value:Boolean):void {
			this["_" + perm] = value;
		}
		
		/**
		 * Gets all the permissions which are true 
		 * @return An array of permissions
		 */		
		public function getPermissions():Array {
			var perm:Array = new Array();
			for each(var permission:Object in permissions) {
				if(this["_" + permission.permission] === true) {
					perm.push(permission.permission);
				}
			}
			
			return perm;
		}

	}
	
}
	/**
	 * Make sure the permissionmanager is used as a singleton 
	 * @author Ids Klijnsma
	 * 
	 */	
	class SingletonEnforcer{}