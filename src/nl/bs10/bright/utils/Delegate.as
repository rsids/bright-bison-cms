/**
*	This clss can be used to create a delegate method. This way you can pass on arguments to a method.
*	@class
*	@author	Arno van Oordt
*/

package nl.bs10.bright.utils {

	public class Delegate extends Object{
		
		public static const VERSION:String = "1.0.0";
		public static const BUILD:int = 1;
		
/**
*	Creates a delegate method. This way you can pass on arguments to a method.
*	@param	method (Funciton) the function that needs to be execute.
*	@param	... (Array) All arguments after the "method" argument are passed on to the delegate method when it's is executed. The arguments are placed after the arguments that are passed on by the call.
*	@return	the created delegate method.
*/
		public static function create(method:Function, ... argArray:Array):Function{
			return function():*{
				return method.apply(null, arguments.concat(argArray));	//return the result of the delegate function
			};
		}
		
	}
}