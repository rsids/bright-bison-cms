package nl.bs10.bright.commands.template
{
	import com.adobe.utils.ArrayUtil;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.Application;
	import mx.events.ModuleEvent;
	import mx.modules.ModuleLoader;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.bright.commands.BrightCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.utils.PluginManager;
	import nl.bs10.brightlib.interfaces.IPlugin;
	import nl.bs10.brightlib.objects.PluginProperties;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class GetPluginsCommand extends BrightCommand implements IAsyncCommand, ICommand {
		private var _loadedPlugins:Number = 0;
		private var _types:Array;
		private var _type:String;
		
		override public function execute(...args):void {
			super.execute(args);
			Model.instance.applicationVO.loadingInfo = "Loading  plugins";
			
			var call:Object = ServiceController.getService("templateService").getPlugins(args[0][0]);
			call.type = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			_type = result.token.type;
			_types = result.result as Array;
			
			if(!Model.instance.templateVO.fieldTypes) {
				Model.instance.templateVO.fieldTypes = new ArrayCollection();
			}
			if(_types.length > 0) {
				_loadPlugins();
				
			} else {
				
				super.resultHandler(event);
			}
			
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
		private function _loadPlugins():void {
			var ml:ModuleLoader = new ModuleLoader();
			var addMaps:Boolean = false;
			var dir:String = (_type == 'core') ? '/' + Model.instance.applicationVO.config.general.cmsfolder + 'assets/plugins/' : '/bright/site/plugins/';
			for each(var type:String in this._types) {
				Model.instance.applicationVO.loadingInfo = "Loading plugin '" + type + "'";
				ml = new ModuleLoader();
				ml.url = dir + "plugin_" + type + ".swf?d=" + new Date().getTime();
				ml.addEventListener(ModuleEvent.READY, _moduleLoaded);
				ml.loadModule();
				switch(type) {
					case  "gmaps":
						addMaps = true;
						ml.percentHeight =
						ml.percentWidth = 100;
						PluginManager.setMaps(ml);
						break;
					/*case  "osm":
						addMaps = true;
						ml.percentHeight =
						ml.percentWidth = 100;
						PluginManager.setMaps(ml);
						break;*/
					case  "linkchooser":
						ml.percentHeight =
						ml.percentWidth = 100;
						PluginManager.setLinkChooser(ml);
						break;
					case  "explorer":
						ml.percentHeight =
						ml.percentWidth = 100;
						PluginManager.setExplorer(ml);
						break;
					default:
						if(Model.instance.applicationVO.config.general.hasOwnProperty("additionalmodules")) {
							if(ArrayUtil.arrayContainsValue(Model.instance.applicationVO.config.general.additionalmodules, type)) {
								ml.percentHeight =
								ml.percentWidth = 100;
								PluginManager.setModule(ml, type);
							}
						}
				}
				Application.application.hiddenBox.addChild(ml);
			}
			if(_type == 'core') {
				Model.instance.applicationVO.mapsAvailable = addMaps;
			}
			Model.instance.applicationVO.setNavitems();
		}
		
		private function _moduleLoaded(event:ModuleEvent):void {
			event.currentTarget.removeEventListener(ModuleEvent.READY, _moduleLoaded);
			if(event.currentTarget.child is IPlugin) {
				var props:PluginProperties = IPlugin(event.currentTarget.child).getProperties();
				if(props.isplugin) {
					Model.instance.templateVO.plugins[props.type] = event.module.factory;
					Model.instance.templateVO.fieldTypes.addItem(props);
				}
				Model.instance.templateVO.pluginProperties.addItem(props);
			}
			_loadedPlugins ++;
			if(_loadedPlugins == _types.length) {
				var s:Sort = new Sort();
				s.fields = [new SortField("pluginname")];
				Model.instance.templateVO.fieldTypes.sort = s;
				Model.instance.templateVO.fieldTypes.refresh();
				Model.instance.templateVO.pluginProperties.sort = s;
				Model.instance.templateVO.pluginProperties.refresh();
				super.resultHandler(event);
			}
		}
		
	}
}