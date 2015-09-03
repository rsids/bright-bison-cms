package nl.bs10.bright.components
{
	import mx.controls.TextInput;
	import mx.events.ValidationResultEvent;
	
	/**
	 * 
	 * @author Ids
	 * Addssourc an error class when the field is invalid 
	 */	
	public class BrightTextInput extends TextInput
	{
		public function BrightTextInput()
		{
			super();
		}
		
		override public function validationResultHandler(event:ValidationResultEvent):void {
			if (event.type == ValidationResultEvent.VALID) {
				styleName = '';
			} else {
				styleName = 'error';
			}
			
			super.validationResultHandler(event);
		}
		
	}
	
	
}