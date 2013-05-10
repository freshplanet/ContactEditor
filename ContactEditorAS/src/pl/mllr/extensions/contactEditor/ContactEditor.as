package pl.mllr.extensions.contactEditor
{

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.geom.Point;
	import flash.system.Capabilities;

	public class ContactEditor extends EventDispatcher
	{

		public static const EXTENSION_ID : String = "pl.mllr.extensions.contactEditor";

		public static const ANDORID_CONTACT_PICK_BY_COMPOSITENAME:String = "vnd.android.cursor.item/contact";
		public static const ANDORID_CONTACT_PICK_BY_PHONE:String = "vnd.android.cursor.item/phone_v2";
		public static const ANDORID_CONTACT_PICK_BY_ADRESS:String = "vnd.android.cursor.item/postal-address_v2";
		
		
		private var context:ExtensionContext = null;
		private static var _set:Boolean = false;
		private static var _isSupp:Boolean = false;
		
		
		/**
		 * initializes contacteditor
		 */
		public function ContactEditor()
		{
			try{
				context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				context.addEventListener(StatusEvent.STATUS, onStatus);
			}catch(e:Error){
				trace(e.message,e.errorID);
			}
		}
		
		/**
		 *Adds contact to AddressBook 
		 * @param name first name
		 * @param lastname last name
		 * @param phone phone number (currently only home supported)
		 * @param company company name
		 * @param email email address (currently only home supported)
		 * @param website website (currently only home supported)
		 * 
		 */		
		public function addContact(name:String,lastname:String="",phone:String="",company:String="",email:String="",website:String=""):void
		{  
			context.call("addContact",name,lastname,phone,company,email,website) ;
		}
		
		/**
		 * gets all contacts from AddressBook 
		 * @return an array of contacts with following: name, lastname, compositename, birthdate, recordId, phones (array), emails (array);
		 * 
		 */		
		public function getContacts():Array
		{
			return context.call("getContacts") as Array;
		}

		/**
		 * 
		 * Shows native window with contact picker 
		 * Listen for ContactEditorEvent.CONTACT_SELECTED or StatusEvent for errors
		 *
		 * @param type - types are defined in this class as static const's
		 */
		public function pickContact(type:String=null):void
		{  
			try{
				context.call("pickContact",type);
			}catch(error:Error){
				if(String(error.message).indexOf("pickContact"))
					trace("pickContact is not supported on this platform");
				else
					throw new Error(error.message,error.errorID);
			}
		}
		/**
		 * 
		 * Sets user image if available
		 * 
		 *
		 * @param recordId - id of contact
		 */
		public function setContactImage(bitmapData:BitmapData,recordId:int):void
		{
			try{
				context.call("setContactImage",bitmapData,recordId);		
			}catch(error:Error){
				if(String(error.message).indexOf("setContactImage"))
					trace("setContactImage is not supported on this platform");
			else
				throw new Error(error.message,error.errorID);
			}
			
		}
		/**
		 * 
		 * Gets user image if available
		 * 
		 *
		 * @param recordId - id of contact
		 */
		public function getContactBitmapData(recordId:int):BitmapData
		{
			try{
				//BitmapData is created on as3 side, since i have no idea how to do this in objective c
				//First we get the dimensions of the image
				var point:Point=context.call("getBitmapDimensions",recordId) as Point;
				if(point && point.x>0)
				{
					//then we create the bitmapdata of specified size
					var bmp:BitmapData=new BitmapData(point.x,point.y);
					//and transfer the actual image to it
					context.call("drawToBitmap",bmp,recordId);
					return bmp;
				}
				
			}catch(error:Error){
				if(String(error.message).indexOf("drawToBitmap"))
					trace("drawToBitmap is not supported on this platform");
				else
					throw new Error(error.message,error.errorID);
			}
			return null;
		}
		
		/**
		 * 
		 * Shows native window that enables contact adding
		 * Listen for ContactEditorEvent.CONTACT_ADDED or StatusEvent for errors
		 *
		 */
		public function addContactInWindow():void
		{
			try{
				context.call("addContactInWindow");
			}catch(error:Error){
				if(String(error.message).indexOf("addContactInWindow"))
					trace("addContactInWindow is not supported on this platform");
				else
					throw new Error(error.message,error.errorID);
			}
		}
		/**
		 * 
		 * Shows native window with contact details
		 * @param recordId recordId of contact in address book
		 * @param isEditable is "edit" button displayed in contact details
		 *
		 */
		public function showContactDetailsInWindow(recordId:int,isEditable:Boolean=false):void
		{
			try{
				context.call("showContactDetailsInWindow",recordId,isEditable);
			}catch(error:Error){
				if(String(error.message).indexOf("showContactDetailsInWindow"))
					trace("showContactDetailsInWindow is not supported on this platform");
				else
					throw new Error(error.message,error.errorID);
			}
		}
		public function canclePickContact():void
		{
			try{
				context.call("pickContact","finish");
			}catch(error:Error){
				if(String(error.message).indexOf("pickContact"))
					trace("pickContact is not supported on this platform");
			}
		}
		
		/**
		 * Gets all contacts from AddressBook following "paging" parameters.
		 *
		 * @param callback function( contacts:Array ):void
		 * @param contactIndex the zero-indexed position from where the ANE will start
		 * retrieving AddressBook contacts
		 * @param pageLength Number of contacts to retrieve in this call.
		 *
		 * @return an array of contacts with following: compositename, recordId; 
		 */	
		public function getContactsSimple( callback:Function, contactIndex:int, pageLength:int ):void
		{  
			this._callback = callback;
			context.call("getContactsSimple", contactIndex, pageLength);
		}
		/**
		 * checks if the user blocked access to address book for this app
		 */
		public function hasPermission():Boolean
		{  
			return context.call("hasPermission") as Boolean;
		}

		private var _callback:Function;


		/**
		 * Gets Details of a Contact.
		 *
		 * @param callback:  function( detailedContact:Object ) :void
		 * 
		 */	
		public function getContactDetails(callback:Function, recordId:int):void
		{  
			this._callback = callback;
			context.call("getContactDetails",recordId);
		}

		
		public function dispose():void{
			if(context){
				context.removeEventListener(StatusEvent.STATUS, onStatus);
				context.dispose();
			}
		}
		/**
		 *returns number of contacts in AddressBook 
		 * @return num of contacts
		 * 
		 */		
		public function getContactCount():int
		{
			return context.call("getContactCount") as int;
		}
		/**
		 *removes contact with specified recordId 
		 * @param recordId record identifier, as set in AddressBook on the device
		 * @return true if contact was removed, false if not found
		 * 
		 */		
		public function removeContact(recordId:int):Boolean
		{
			return context.call("removeContact",recordId) as Boolean;
		}
		/**
		 * Whether the ContactEditor is available on the device (true);<br>otherwise false
		 */
		public static function get isSupported():Boolean{
			if(!_set){// checks if a value was set before
				try{
					_set = true;
						var _context:ExtensionContext = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
						_isSupp = _context.call("contactEditorIsSupported");
						_context.dispose();
				}catch(e:Error){
					trace(e.message,e.errorID);
					return _isSupp;
				}
			}	
			return _isSupp;

		}

		protected function onStatus(event:StatusEvent):void
		{
			var callback:Function = _callback;
			var fromNativeExtension:Object;
			if (event.code == ContactEditorEvent.SIMPLE_CONTACTS_READY)
			{
				if (callback != null)
				{
					_callback = null;
					fromNativeExtension = context.call("retrieveSimpleContacts");
					callback( fromNativeExtension as Array);
				}
			}
			else if (event.code == ContactEditorEvent.DETAILED_CONTACT_READY)
			{
				if (callback != null)
				{
					_callback = null;
					fromNativeExtension = context.call("retrieveDetailedContact");
					callback(fromNativeExtension);
				}
			}
			else if(event.code==ContactEditorEvent.CONTACT_SELECTED)
			{
				this.dispatchEvent(new ContactEditorEvent(ContactEditorEvent.CONTACT_SELECTED,event.level));
			}
			else if(hasEventListener(StatusEvent.STATUS))
			{
				this.dispatchEvent(event.clone());
			}
			else {
				trace(event.type+"   "+event.code+"  "+event.level);
			}
		}

	}
}





