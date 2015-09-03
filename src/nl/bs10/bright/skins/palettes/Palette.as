package nl.bs10.bright.skins.palettes {
	
	import nl.fur.vein.model.BaseModel;
	
	[Bindable]
	public class Palette extends BaseModel {
		
		public var fills:Fills = new Fills();
		public var strokes:Strokes = new Strokes();
		public var filters:Filters = new Filters();
		
		public var base_radius:int = 5;		
		
		private static var _palette:Palette;
		
		public static function get instance():Palette {
			if(_palette == null ) 
				_palette = new Palette();
				
			return _palette;
		}
		
		
		public function Palette():void {
			super();			
		}
	}
	
}