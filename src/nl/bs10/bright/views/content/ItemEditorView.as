package nl.bs10.bright.views.content {
	
	import com.adobe.utils.StringUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.system.System;
	
	import mx.containers.VBox;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.DateField;
	import mx.controls.TabBar;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.page.GenerateLabelCommand;
	import nl.bs10.bright.commands.tree.AddPageCommand;
	import nl.bs10.bright.commands.tree.CheckLockCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.vo.CalendarVO;
	import nl.bs10.bright.model.vo.ElementVO;
	import nl.bs10.bright.model.vo.MarkerVO;
	import nl.bs10.bright.model.vo.PageVO;
	import nl.bs10.bright.model.vo.TemplateVO;
	import nl.bs10.bright.utils.PluginManager;
	import nl.bs10.bright.views.files.FilePopupView;
	import nl.bs10.brightlib.components.BrightDateField;
	import nl.bs10.brightlib.components.PluginBox;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.events.FileExplorerEvent;
	import nl.bs10.brightlib.interfaces.IContentVO;
	import nl.bs10.brightlib.interfaces.IPage;
	import nl.bs10.brightlib.interfaces.IPlugin;
	import nl.bs10.brightlib.objects.Page;
	import nl.bs10.brightlib.objects.Template;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;

	public class ItemEditorView extends VBox {
		
		[Bindable] public var title:String;
		
		private var _iconsSet:Boolean = false;
		private var _itemChanged:Boolean = false;
		private var _typeChanged:Boolean = false;
		private var _saveCommand:ICommand;
		
		private var _contentVO:IContentVO;
		
		private var _type:String = "page";
		
		private var _titlerequired:Boolean;
		
		/**
		 * Holds the templates 
		 */		
		[Bindable] public var types_cmb:ComboBox;
		[Bindable] public var item_vs:ViewStack;
		[Bindable] public var lang_tb:TabBar;
		[Bindable] public var label_txt:TextInput;
		[Bindable] public var pubdate_df:BrightDateField;
		[Bindable] public var expdate_df:BrightDateField;
		[Bindable] public var showinnav_chb:CheckBox;
		[Bindable] public var always_chb:CheckBox;
		
		[Bindable(event="contentVOChanged")]
		public function set contentVO(value:IContentVO):void {
			if(value !== _contentVO) {
				if(_contentVO)
					_contentVO.removeEventListener("ItemChanged", _itemChangedHandler);
					
				_contentVO = value;
				
				if(_contentVO is CalendarVO) {
					_type = "calendar";
				}else if(_contentVO is ElementVO) {
					_type = "element";
				}else if(_contentVO is MarkerVO) {
					_type = "marker";
				}else {
					_type = "page";
				}
				
				_contentVO.addEventListener("ItemChanged", _itemChangedHandler, false, 0, true);
				
				dispatchEvent(new Event("contentVOChanged"));
			}
		}
		
		public function get contentVO():IContentVO {
			return _contentVO;
		}
		
		public function ItemEditorView(titlerequired:Boolean = true) {
			super();
			_titlerequired = titlerequired;
			_itemChangedHandler();
		}
		
		public function cancel(currentItem:IPage = null):void {
			while(item_vs.numChildren > 1) {
				//_dispose(item_vs.removeChildAt(0) as PluginBox);
				
				var item:PluginBox = item_vs.getChildAt(0) as PluginBox;
				item.dispose();
				_dispose(item);
				item_vs.removeChildAt(0);
			}
			System.gc();
			if(_contentVO && _contentVO.currentItem) {
				_contentVO.currentItem.content = null;
				_contentVO.currentItem = null;
			}
			_contentVO.currentDefinition = null;
		}
		
		protected function typeChangeHandler(event:Event = null):void {
			_contentVO.currentDefinition = types_cmb.selectedItem as Template;
			
			if(_contentVO.currentItem) {
				if(_contentVO.currentDefinition) {
					_contentVO.currentItem.itemType = _contentVO.currentDefinition.id;
				} else {
					_contentVO.currentItem.itemType = Number.NaN;
				}
			}
				
			_typeChanged = true;
			invalidateProperties();
		}
		
		protected function updateLabel():void {
			_contentVO.currentItem.label = label_txt.text;
			if(StringUtil.trim(label_txt.text) != '') 
				CommandController.addToQueue(new GenerateLabelCommand(), _contentVO, _type);
		}		
		
		
		protected function setDate(date:String):void {
			if(date == "publicationdate")
				(_contentVO.currentItem as Page).flpublicationdate = pubdate_df.selectedDate; 
			if(date == "expirationdate")
				(_contentVO.currentItem as Page).flexpirationdate = expdate_df.selectedDate; 
		}
		
		protected function alwayspublishedChanged(value:Boolean):void {
			_contentVO.currentItem.alwayspublished = value;
		}
		protected function showinnavChanged(value:Boolean):void {
			_contentVO.currentItem.showinnavigation = value;
		}
		
		protected function save(callcancel:Boolean = true, error:Array = null):void {
			var fn:Function = (callcancel) ? cancel : null;
			
			if(!error)
				error = new Array();
			
			error = processContent(error);
			
			if(label_txt.text == "" && _contentVO.currentItem.content.title) {
				 for each (var lang:String in Model.instance.applicationVO.config.general.languages) {
				 	if(_contentVO.currentItem.content.title[lang] && _contentVO.currentItem.content.title[lang] != "") {
				 		label_txt.text = _contentVO.currentItem.content.title[lang];
				 		updateLabel();
				 		break;
				 	}
				 }
			}
			
			if(error.length == 0) {
				// Execute command
				
				if(contentVO.currentDefinition && contentVO.currentDefinition.templatetype == TemplateVO.PAGETEMPLATE && Model.instance.structureVO.currentItem) {
					CommandController.addToQueue(new AddPageCommand(), Model.instance.structureVO.currentItem, Model.instance.structureVO.currentItem, Model.instance.structureVO.currentItem.index, cancel);
				} else {
					contentVO.save(fn);					
				}
				
			} else {
				Alert.show(error.join("\n"), "Cannot save page");
			}
		}
		
		protected function saveas():void {
			var error:Array = processContent(new Array());
			
			if(error.length == 0) {
				// Show Popup
				var popup:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject, LabelPopupViewLayout, true);
				LabelPopupViewLayout(popup).callback = cancel;
				LabelPopupViewLayout(popup).contentVO = contentVO;
				PopUpManager.centerPopUp(popup);
			} else {
				Alert.show(error.join("\n"), "Cannot save page");
			}
		}
		
		protected function setViewStack(event:Event):void {
			if(!_contentVO.currentDefinition && lang_tb.selectedIndex < contentVO.tabs.length - 1) {
				Alert.show("Choose a template first!", "Choose template");
				lang_tb.selectedIndex = contentVO.tabs.length - 1;
				return;
			}
			item_vs.selectedIndex = lang_tb.selectedIndex;
		}
		
		protected function processContent(error:Array):Array {
			var content:Object = {};
			
			// -1, last tab is settings tab
			var nc:int = item_vs.numChildren - 1;
			for(var i:int = 0; i < nc; i++ ){
				error = PluginBox(item_vs.getChildAt(i)).validate(content, error);
			}
			_contentVO.currentItem.content = content;
			
			if(_titlerequired && !content.title) {
				error.push("The field 'title' is required");
			}
			return error;
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_itemChanged) {
				_itemChanged = false;
				
				
				if(!_contentVO.currentItem)
					return;

				label_txt.enabled = false;
				CommandController.addToQueue(new CheckLockCommand(), _contentVO.currentItem.pageId, label_txt);
				
				if(showinnav_chb) {
					showinnav_chb.selected = _contentVO.currentItem.showinnavigation;
					always_chb.selected = _contentVO.currentItem.alwayspublished;
				}
				
				if(_contentVO.currentItem.pageId > 0) {
					
					for each(var def:Template in Model.instance.templateVO.rawTemplateDefinitions) {
						
						if(def.id == _contentVO.currentItem.itemType) {
							_contentVO.currentDefinition = def;
							
							if(types_cmb)
								types_cmb.selectedItem = def;
						}
					}
				} else {
					types_cmb.selectedIndex = -1;
				}
			}
			
			if(_typeChanged) {
				_typeChanged = false;
				
				var settings:DisplayObject;
				while(item_vs.numChildren > 1) {
					var item:PluginBox = item_vs.getChildAt(0) as PluginBox;
					item.dispose();
					_dispose(item);
					item_vs.removeChildAt(0);
				}
				settings = item_vs.removeChildAt(0);
				
				//var definition:Object = _contentVO.currentDefinition;
				var page:IPage = _contentVO.currentItem;
				
				if(page) {
					// -2, last item is settings page 
					var i:int = contentVO.tabs.length - 2;
					var plugin:IPlugin;
					
					for(i; i >= 0; i--) {
						var lang:String = contentVO.tabs.getItemAt(i).value;
						var langvb:PluginBox = new PluginBox();
						langvb.percentHeight = 100;
						langvb.percentWidth = 100;
						langvb.verticalScrollPolicy = "on";
						
						langvb.plugins = Model.instance.templateVO.plugins;
						langvb.addTitle = _titlerequired;
						langvb.template = _contentVO.currentDefinition;
						langvb.setValues(page.content, lang);
						langvb.addEventListener(FileExplorerEvent.OPENFILEEXPLOREREVENT, _openFileExplorer, false, 0, true);
						langvb.addEventListener(BrightEvent.DATAEVENT, _dataEventHandler, false, 0, true);
						
						item_vs.addChildAt(langvb, 0);
					}
					
					item_vs.addChild(settings);
					
					var index:int = (page.pageId == 0 || _contentVO.currentDefinition == null) ? item_vs.numChildren - 1 : 0;
					
					lang_tb.selectedIndex =
					item_vs.selectedIndex = index;
				} else {
					// Only re-add settings page
					item_vs.addChild(settings);
				}
				
			}
		}
		
		/**
		 * Remove listeners for gc
		 */		
		private function _dispose(item:PluginBox):void {
			item.removeEventListener(FileExplorerEvent.OPENFILEEXPLOREREVENT, _openFileExplorer);
			item.removeEventListener(BrightEvent.DATAEVENT, _dataEventHandler);
		}
		
		private function _itemChangedHandler(event:Event = null):void {
			_itemChanged = true;
			_typeChanged = true;
			invalidateProperties();
		}
		
		private function _openFileExplorer(event:FileExplorerEvent):void {
			var p:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject,
																FilePopupView,
																true);
			FilePopupView(p).setProperties(event);
			PopUpManager.centerPopUp(p);
		}
		
		private function _dataEventHandler(event:BrightEvent):void {
			PluginManager.handleDataEvent(event);
		}

		public function get saveCommand():ICommand
		{
			return _saveCommand;
		}

		public function set saveCommand(value:ICommand):void
		{
			_saveCommand = value;
		}

		
	}
}