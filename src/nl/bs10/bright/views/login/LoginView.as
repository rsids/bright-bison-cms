package nl.bs10.bright.views.login {
	import flash.events.Event;
	
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.TextInput;
	
	import nl.bs10.bright.commands.administrators.AuthenticateCommand;
	import nl.bs10.bright.model.Model;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.events.VeinDispatcher;
	import nl.fur.vein.events.VeinEvent;

	public class LoginView extends VBox {
		
		[Bindable] public var email_txt:TextInput;
		[Bindable] public var password_txt:TextInput;
		[Bindable] public var store_session_chb:CheckBox;
		[Bindable] public var login_btn:Button;
		
		public function init():void {
			addEventListener(Event.REMOVED_FROM_STAGE, _reset, false, 0, true);
			VeinDispatcher.instance.addEventListener('authenticateResult', _onAuthenticateResult);
		}
		
		
		protected function login():void {
			login_btn.enabled = false;
			Model.instance.administratorVO.lastLoginAttempt = new Date();
			Model.instance.administratorVO.lastLoginEmail = email_txt.text;
			Model.instance.administratorVO.lastLoginPassword = password_txt.text;
			CommandController.addToQueue(new AuthenticateCommand(), email_txt.text, password_txt.text);
		}
		
		private function _reset(event:Event):void {
			email_txt.text = "";
			password_txt.text = "";
			login_btn.enabled = true;
		}
		
		private function _onAuthenticateResult(event:VeinEvent):void {
			if(event.data === false) {
				login_btn.enabled = true;
			}
		}
		
	}
}