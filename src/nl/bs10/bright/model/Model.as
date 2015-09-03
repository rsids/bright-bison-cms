package nl.bs10.bright.model {
	
	import nl.bs10.bright.model.vo.*;
	import nl.fur.vein.model.BaseModel;
	
	public class Model extends BaseModel {
		
		[Bindable] public var administratorVO:AdministratorVO = new AdministratorVO();
		[Bindable] public var applicationVO:ApplicationVO = new ApplicationVO();
		[Bindable] public var calendarVO:CalendarVO = new CalendarVO();
		[Bindable] public var elementVO:ElementVO = new ElementVO();
		[Bindable] public var mailingVO:MailingVO = new MailingVO();
		[Bindable] public var mapsVO:MapsVO = new MapsVO();
		[Bindable] public var markerVO:MarkerVO = new MarkerVO();
		[Bindable] public var pageVO:PageVO = new PageVO();
		[Bindable] public var polyVO:PolyVO = new PolyVO();
		[Bindable] public var settingsVO:SettingsVO = new SettingsVO();
		[Bindable] public var structureVO:StructureVO = new StructureVO();
		[Bindable] public var templateVO:TemplateVO = new TemplateVO();
		[Bindable] public var userVO:UserVO = new UserVO();
		
		public function Model():void {
			super();
		}
		
		//[Bindable]
		private static var _model:Model;

		public static function get instance():Model {
			if(_model == null) 
				_model = new Model();
			return _model;
		}
	}
}