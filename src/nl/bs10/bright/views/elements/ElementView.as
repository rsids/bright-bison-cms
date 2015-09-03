package nl.bs10.bright.views.elements {
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.containers.HDividedBox;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	import mx.events.FlexEvent;
	
	import nl.bs10.bright.commands.elements.DeleteElementCommand;
	import nl.bs10.bright.commands.elements.FilterElementsCommand;
	import nl.bs10.bright.commands.elements.GetElementCommand;
	import nl.bs10.bright.commands.elements.GetElementsCommand;
	import nl.bs10.bright.components.LazyDataGrid;
	import nl.bs10.bright.controllers.SettingsController;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.model.vo.TemplateVO;
	import nl.bs10.brightlib.controllers.DatagridController;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.objects.Page;
	import nl.bs10.brightlib.objects.Template;
	import nl.fur.vein.controllers.CommandController;

	public class ElementView extends HDividedBox {
		
		[Bindable] public var element_dg:LazyDataGrid;
		[Bindable] public var dg_vbox:VBox;
		[Bindable] public var filter_txt:TextInput;
		[Bindable] public var elementEditorView:ElementEditorViewLayout; 
		
		private var _filterTimeout:uint;
		private var _columnsChanged:Boolean;
		
		protected function showHandler():void {
			CommandController.addToQueue(new GetElementsCommand());
			for each(var template:Template in Model.instance.templateVO.rawTemplateDefinitions) {
				if(template.templatetype == TemplateVO.ELEMENTTEMPLATE) {
					Model.instance.elementVO.template = template;
					break;
				}
			}
			if(!Model.instance.elementVO.template)
				Alert.show("No element template found", "Create a element template");
			Model.instance.elementVO.addEventListener("ItemChanged", _elementChangedHandler, false, 0, true)
		}
		
		protected function addElement():void {
			Model.instance.elementVO.currentItem = new Page();
		}
		
		protected function elementview1_creationCompleteHandler(event:FlexEvent):void{
			Model.instance.administratorVO.addEventListener('settingsChanged', _onSettingsChange);
			_columnsChanged = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_columnsChanged) {
				_columnsChanged = false;
				if(!Model.instance.administratorVO.getSetting('element.visibleColumns')) {
					Model.instance.administratorVO.setSetting('element.visibleColumns', Model.instance.applicationVO.config.columns.element);
				}
				DatagridController.setDataGridColumns(element_dg, Model.instance.administratorVO.getSetting('element.visibleColumns'));
				
			}
		}
		
		protected function deleteElement():void {
			Alert.show("Are you sure you want to delete this / these element(s)?", "Please confirm", Alert.YES|Alert.CANCEL, null, _deleteElementHandler);
		}
		
		protected function editColumns():void {
			SettingsController.getEditColumnsPopup(Model.instance.applicationVO.config.columns.element, Model.instance.templateVO.elementDefinitions,'element.visibleColumns');
		}
		
		protected function editElement():void {
			CommandController.addToQueue(new GetElementCommand(), element_dg.selectedItem.pageId);
		} 
		
		protected function onFilterUp(event:KeyboardEvent):void {
			clearTimeout(_filterTimeout);
			_filterTimeout = setTimeout(function():void {
				var fltr:String = (filter_txt.text != '') ? filter_txt.text : null;
				Model.instance.elementVO.filter = fltr;
				Model.instance.applicationVO.isLoading = true;
				_filterelements();
		
			}, 200);
		}
		
		
		protected function onBottomReached(event:Event):void {
			CommandController.addToQueue(new FilterElementsCommand(), 
										Model.instance.elementVO.aelements.length, 
										Model.instance.elementVO.filter, 
										Model.instance.administratorVO.getSetting('element.defaultsort'), 
										Model.instance.administratorVO.getSetting('element.defaultsortdir'));	
		}
		
		protected function onHeaderRelease(event:DataGridEvent):void {
			Model.instance.administratorVO.callbacks.push(_filterelements);
		}
		
		protected function sortByType(a:Object, b:Object):int {
			return (a.itemType > b.itemType) ? 1 : -1;
		} 
		
		private function _deleteElementHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES)
				CommandController.addToQueue(new DeleteElementCommand(), element_dg.selectedItems);
		}
		
		private function _elementChangedHandler(event:Event):void {
			if(Model.instance.elementVO.currentItem) {
				dg_vbox.percentWidth = 25;
				elementEditorView.percentWidth = 75;
			} else {
				dg_vbox.percentWidth = 100;
				elementEditorView.percentWidth = 0;
			}		
		}
		
		private function _filterelements():void {
			CommandController.addToQueue(new FilterElementsCommand(), 
											0, Model.instance.elementVO.filter, 
											Model.instance.administratorVO.getSetting('element.defaultsort'), 
											Model.instance.administratorVO.getSetting('element.defaultsortdir'));
		}
		
		/**
		 * _onSettingsChange function
		 *  
		 **/
		private function _onSettingsChange(event:BrightEvent):void {
			if(event.data == 'element.visibleColumns') {
				_columnsChanged = true;
				invalidateProperties();
			}
		}
	}
}