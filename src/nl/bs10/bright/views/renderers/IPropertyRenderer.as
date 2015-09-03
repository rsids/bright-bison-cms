package nl.bs10.bright.views.renderers
{
	public interface IPropertyRenderer
	{
		function set label(value:String):void;
		function get label():String;
		
		function set property(value:*):void;
		function get property():*;
	}
}