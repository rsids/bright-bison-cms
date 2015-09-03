package nl.bs10.bright.views.templates {
	import com.adobe.utils.StringUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.ComboBox;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.NumericStepper;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import nl.bs10.bright.commands.template.GetParsersCommand;
	import nl.bs10.bright.commands.template.SetTemplateCommand;
	import nl.bs10.bright.model.Model;
	import nl.bs10.bright.views.renderers.FieldRenderer;
	import nl.bs10.bright.views.renderers.FieldRendererLayout;
	import nl.bs10.brightlib.components.Prompt;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.fur.vein.controllers.CommandController;

	public class TemplateEditView extends Canvas {
		
		private var _templateChanged:Boolean = false;
		private var _parsersChanged:Boolean = false;
		private var _iconChanged:Boolean = false;
		private var _typeChanged:Boolean = false;
		
		[Bindable] public var parser_lbl:Label;
		[Bindable] public var fields_vb:VBox;
		[Bindable] public var icon_img:Image;
		[Bindable] public var types_cmb:ComboBox;
		[Bindable] public var parser_cmb:ComboBox;
		[Bindable] public var displaylabel_txt:TextInput;
		[Bindable] public var label_txt:TextInput;
		[Bindable] public var priority_ns:NumericStepper;
		[Bindable] public var maxchildren_ns:NumericStepper;
		[Bindable] public var lifetime_txt:TextInput;
		
		public function TemplateEditView():void {
			addEventListener(FlexEvent.CREATION_COMPLETE, _creationCompleteHandler);
		}
		
		public function iconChanged():void {
			_iconChanged = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_iconChanged && Model.instance.templateVO.selectedTemplate) {
				icon_img.source = IconController.getIcon(Model.instance.templateVO.selectedTemplate, 'icon');
				_iconChanged = false;
				if(!icon_img.source) {
					icon_img.graphics.clear();
					icon_img.graphics.lineStyle(1, 0x000000);
					icon_img.graphics.drawRect(0,0,16,16);
					icon_img.graphics.moveTo(0,0);
					icon_img.graphics.lineTo(16,16);
					icon_img.graphics.moveTo(0,16);
					icon_img.graphics.lineTo(16,0);
				}
			}
			
			if(_templateChanged && Model.instance.templateVO.selectedTemplate) {
				
				_templateChanged = false;
				fields_vb.removeAllChildren();
				
				for each(var t:Object in Model.instance.templateVO.types) {
					if(t.type == Model.instance.templateVO.selectedTemplate.templatetype) {
						types_cmb.selectedItem = t;
						break;
					}
				}
				
				if(Model.instance.templateVO.selectedTemplate.fields) {
					
					for each(var field:Object in Model.instance.templateVO.selectedTemplate.fields) {
						var fr:FieldRendererLayout = addField();
						fr.data = field;
					}
				}
				_typeChanged = true;
			}
			
			if(_parsersChanged && Model.instance.templateVO.selectedTemplate) {
				_parsersChanged = false;
				for each(var parser:Object in Model.instance.templateVO.parsers) {
					if(parser.parserId == Model.instance.templateVO.selectedTemplate.parser) {
						parser_cmb.selectedItem = parser;
					}
				}
			}
			
			if(_typeChanged) {
				_typeChanged = false;
				if(types_cmb.selectedIndex == 0) {
					parser_lbl.visible = 
					parser_cmb.visible = 
					priority_ns.enabled = 
					lifetime_txt.enabled = 
					maxchildren_ns.enabled = true;
				} else {
					parser_lbl.visible = 
					parser_cmb.visible = 
					priority_ns.enabled = 
					lifetime_txt.enabled = 
					maxchildren_ns.enabled = false;
					maxchildren_ns.value = 0;
				}
			}
		}
		
		protected function chooseIcon():void {
			var ifd:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject, TemplateIconView, true);
			TemplateIconView(ifd).opener = this;
			PopUpManager.centerPopUp(ifd);
		}
		
		protected function checkDigit():void {
			var lbl:String = label_txt.text;
			var needchecking:Boolean = true;
			while(lbl.length != 0 && needchecking) {
				if((lbl.charCodeAt(0) > 47 && lbl.charCodeAt(0) < 58) || lbl.charCodeAt(0) == 45 || lbl.charCodeAt(0) == 95) {
					lbl = lbl.substr(1);
				} else {
					needchecking = false;
				}
			}
			label_txt.text = lbl;
		}
		
		protected function saveTemplate(saveas:Boolean = false):void {
			var errors:Array = new Array();
			Model.instance.templateVO.selectedTemplate.itemtype = StringUtil.trim(label_txt.text);
			if(Model.instance.templateVO.selectedTemplate.itemtype == '') 
				errors.push('The label of a template cannot be empty');
			
			if(String(Model.instance.templateVO.selectedTemplate.itemtype).charCodeAt(0) < 97 || String(Model.instance.templateVO.selectedTemplate.itemtype).charCodeAt(0) > 122)
					errors.push("The label cannot start with a number");
					
			Model.instance.templateVO.selectedTemplate.lifetime = StringUtil.trim(lifetime_txt.text);
			if(Model.instance.templateVO.selectedTemplate.lifetime == '')
				Model.instance.templateVO.selectedTemplate.lifetime = '0 hours';
			
			Model.instance.templateVO.selectedTemplate.templatename = StringUtil.trim(displaylabel_txt.text);
			if(Model.instance.templateVO.selectedTemplate.templatename == '') 
				errors.push('The displaylabel of a template cannot be empty');
				
			Model.instance.templateVO.selectedTemplate.priority = priority_ns.value;
			Model.instance.templateVO.selectedTemplate.maxchildren = maxchildren_ns.value;
			Model.instance.templateVO.selectedTemplate.parser = (parser_cmb.selectedItem) ? parser_cmb.selectedItem.parserId : 1;
			Model.instance.templateVO.selectedTemplate.templatetype = (types_cmb.selectedItem) ? types_cmb.selectedItem.type : 0;
			
			var fields:Array = new Array();
			
			var children:Array = fields_vb.getChildren();
			var index:int = 0;
			var labels:Object = {};
			for each(var fr:FieldRenderer in children) {
				var fd:Object = fr.data;
				fd.label = StringUtil.trim(fd.label);
				if(!fd.type) {
					errors.push('You must select a template type');
				}
				if(fd.label == '') {
					errors.push('The label of a field can not be emtpy');
				
				} else if(fd.label == 'title') {
					errors.push("'title' is a preserved word");
				
				} else if(labels.hasOwnProperty(fd.label)) {
					errors.push("The label of a field must be a unique string");
				
				} else if(String(fd.label).charCodeAt(0) < 97 || String(fd.label).charCodeAt(0) > 122) {
					errors.push("The label of a field cannot start with a number");
				}
				
				labels[fd.label] = true;
				
				fd.index = index;
				fields.push(fd);
				index++;
			}
			
			if(errors.length == 0) {
				Model.instance.templateVO.selectedTemplate.fields = fields;
				if(saveas) {
					Prompt.show("Enter the new label of the template", 
								"Enter label", 
								function(event:BrightEvent):void {
									Model.instance.templateVO.selectedTemplate.itemtype = event.data.toString();
									Model.instance.templateVO.selectedTemplate.id = 0;
									CommandController.addToQueue(new SetTemplateCommand(), Model.instance.templateVO.selectedTemplate, false);
								}, 'a-z0-9');
				} else {
					CommandController.addToQueue(new SetTemplateCommand(), Model.instance.templateVO.selectedTemplate, false);
				}
			
			} else {
				Alert.show("Cannot save your template:\n- " + errors.join("\n- "), "Cannot save");
			}
		}
		
		protected function addField():FieldRendererLayout {
			var fr:FieldRendererLayout = new FieldRendererLayout();
			fields_vb.addChild(fr);
			fr.addEventListener("MOVE_UP", _moveUp, false, 0, true);
			fr.addEventListener("MOVE_DOWN", _moveDown, false, 0, true);
			return fr;
		}
		
		protected function close():void {
			Model.instance.templateVO.selectedTemplate = null;
		}
		
		protected function typeChanged():void {
			_typeChanged = true;
			invalidateProperties();
		}
		
		private function _moveDown(event:Event):void {
			var index:int = fields_vb.getChildIndex(event.currentTarget as DisplayObject);
			if(index < fields_vb.numChildren - 1)
				fields_vb.addChildAt(fields_vb.removeChildAt(index), index+1);
		}
		
		private function _moveUp(event:Event):void {
			var index:int = fields_vb.getChildIndex(event.currentTarget as DisplayObject);
			if(index > 0)
				fields_vb.addChildAt(fields_vb.removeChildAt(index), index-1);
		}
		
		/**
		 * _onParsersChanged function
		 *  
		 **/
		private function _onParsersChanged(event:Event):void {
			Model.instance.templateVO.removeEventListener('parsersChanged', _onParsersChanged);
			_parsersChanged = true;
			invalidateProperties();
		}
		
		private function _selectedTemplateChangedHandler(event:Event):void {
			
			_templateChanged = true;
			_iconChanged = true;
			invalidateProperties();
		}
		
		private function _creationCompleteHandler(event:FlexEvent):void {
			CommandController.addToQueue(new GetParsersCommand());
			Model.instance.templateVO.addEventListener('parsersChanged', _onParsersChanged, false, 0, true);
			Model.instance.templateVO.addEventListener('selectedTemplateChanged', _selectedTemplateChangedHandler, false, 0, true);
			removeEventListener(FlexEvent.CREATION_COMPLETE, _creationCompleteHandler);
		}
		
	}
}