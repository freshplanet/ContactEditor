package pl.mllr.extensions.contactEditor
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class ContactEditor extends EventDispatcher
	{
		///////////////////////////////////////////////////////////////////////////////////////////
		// 	PUBLIC API
		///////////////////////////////////////////////////////////////////////////////////////////
		
		public static function get isSupported() : Boolean
		{
			return Capabilities.manufacturer.indexOf("iOS") != -1 || 
				Capabilities.manufacturer.indexOf("Android") != -1;
		}
		
		public function ContactEditor()
		{
			if (!_instance)
			{
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID,null);
				if (!_context)
				{
					throw Error("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);
				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}
		
		public static function getInstance():ContactEditor
		{
			return _instance ? _instance : new ContactEditor();
		}
		
		/**
		 * Retrieves the number of contacts stored on the device's address book.<br/><br/>
		 * 
		 * For some devices, specially iOS 6.0, access to a device's AddressBook API is async
		 * which means that callback functions are used.<br/><br/>
		 * 
		 * Possible error codes dispatched by the Native Extension:
		 * <ul>
		 * <li>ADDRESS_BOOK_ACCESS_DENIED : Developers should display a message 
		 * asking users to grant access to the AddressBook for the application (iOS Only)</li>
		 * </ul>
		 *  
		 * @param callback function to be called when the native extension is done:  
		 * the function should have the following signature: 
		 * function( count:int, errorCode:String ):void
		 */
		public function getContactCount( callback:Function ):void
		{
			_callback = callback;
			_context.call("getContactCount");
		} 
		
		/**
		 * Retrieve contacts (recordId, compositeName) stored in the address book.<br/><br/>
		 * 
		 * For performance optimization, this method allows retrieving the data in batches.  
		 * You can use Adobe Scout to find a good batch size that will not impact your FPS, and 
		 * distribute your batches in several frames.
		 *  
		 * @param callback callback function to be called when the native extension is done:  
		 * the function should have the following signature: 
		 * function( count:int, errorCode:String ):void
		 * @param batchStart where should each batch start (zero-indexed).
		 * @param batchLength how many elements should be retrieved this batch.
		 */
		public function getContactsSimple( callback:Function, batchStart:int, batchLength:int ):void
		{  
			_callback = callback;
			_context.call("getContactsSimple", batchStart, batchLength);
		}
		
		
		///////////////////////////////////////////////////////////////////////////////////////////
		// 	PRIVATE API
		///////////////////////////////////////////////////////////////////////////////////////////
		
		private static const EXTENSION_ID : String = "pl.mllr.extensions.contactEditor";
		
		private static var _instance : ContactEditor;
		
		private var _context : ExtensionContext;
		
		private var _callback:Function;
		
		private function onStatus( event:StatusEvent ) : void
		{
			var callback:Function = _callback;
			
			if (event.code == "ADDRESS_BOOK_ACCESS_DENIED")
			{
				_callback = null;
				callback(null, event.code);
			}
			else if (event.code == "NUM_CONTACT_UPDATED")
			{
				_callback = null;
				var numContacts: int = int(event.level);
				callback(numContacts, null);
			}
			else if (event.code == "SIMPLE_CONTACTS_UPDATED")
			{
				_callback = null;
				var simpleContacts:Array = _context.call("retrieveSimpleContacts") as Array;
				callback(simpleContacts, null);
			}
			else
			{
				trace("[ContactEditor] onStatus: ", event.code, event.level);
			}
		}
		
		
		
		
//		public static const EXTENSION_ID : String = "pl.mllr.extensions.contactEditor";
//
//		public static const ANDORID_CONTACT_PICK_BY_COMPOSITENAME:String = "vnd.android.cursor.item/contact";
//		public static const ANDORID_CONTACT_PICK_BY_PHONE:String = "vnd.android.cursor.item/phone_v2";
//		public static const ANDORID_CONTACT_PICK_BY_ADRESS:String = "vnd.android.cursor.item/postal-address_v2";
//		
//		
//		private var context:ExtensionContext = null;
//		private static var _set:Boolean = false;
//		private static var _isSupp:Boolean = false;
		
		
		
		
		
//		/**
//		 * gets all contacts from AddressBook 
//		 * @return an array of contacts with following: name, lastname, compositename, birthdate, recordId, phones (array), emails (array);
//		 * 
//		 */		
//		public function getContacts():Array
//		{
//			return context.call("getContacts") as Array;
//		}
//
//		/**
//		 * 
//		 * Shows native window with contact picker 
//		 * Listen for ContactEditorEvent.CONTACT_SELECTED or StatusEvent for errors
//		 *
//		 * @param type - types are defined in this class as static const's
//		 */
//		public function pickContact(type:String=null):void
//		{  
//			try{
//				context.call("pickContact",type);
//			}catch(error:Error){
//				if(String(error.message).indexOf("pickContact"))
//					trace("pickContact is not supported on this platform");
//				else
//					throw new Error(error.message,error.errorID);
//			}
//		}
//		/**
//		 * 
//		 * Sets user image if available
//		 * 
//		 *
//		 * @param recordId - id of contact
//		 */
//		public function setContactImage(bitmapData:BitmapData,recordId:int):void
//		{
//			try{
//				context.call("setContactImage",bitmapData,recordId);		
//			}catch(error:Error){
//				if(String(error.message).indexOf("setContactImage"))
//					trace("setContactImage is not supported on this platform");
//			else
//				throw new Error(error.message,error.errorID);
//			}
//			
//		}
//		/**
//		 * 
//		 * Gets user image if available
//		 * 
//		 *
//		 * @param recordId - id of contact
//		 */
//		public function getContactBitmapData(recordId:int):BitmapData
//		{
//			try{
//				//BitmapData is created on as3 side, since i have no idea how to do this in objective c
//				//First we get the dimensions of the image
//				var point:Point=context.call("getBitmapDimensions",recordId) as Point;
//				if(point && point.x>0)
//				{
//					//then we create the bitmapdata of specified size
//					var bmp:BitmapData=new BitmapData(point.x,point.y);
//					//and transfer the actual image to it
//					context.call("drawToBitmap",bmp,recordId);
//					return bmp;
//				}
//				
//			}catch(error:Error){
//				if(String(error.message).indexOf("drawToBitmap"))
//					trace("drawToBitmap is not supported on this platform");
//				else
//					throw new Error(error.message,error.errorID);
//			}
//			return null;
//		}
//		
//		/**
//		 * 
//		 * Shows native window that enables contact adding
//		 * Listen for ContactEditorEvent.CONTACT_ADDED or StatusEvent for errors
//		 *
//		 */
//		public function addContactInWindow():void
//		{
//			try{
//				context.call("addContactInWindow");
//			}catch(error:Error){
//				if(String(error.message).indexOf("addContactInWindow"))
//					trace("addContactInWindow is not supported on this platform");
//				else
//					throw new Error(error.message,error.errorID);
//			}
//		}
//		/**
//		 * 
//		 * Shows native window with contact details
//		 * @param recordId recordId of contact in address book
//		 * @param isEditable is "edit" button displayed in contact details
//		 *
//		 */
//		public function showContactDetailsInWindow(recordId:int,isEditable:Boolean=false):void
//		{
//			try{
//				context.call("showContactDetailsInWindow",recordId,isEditable);
//			}catch(error:Error){
//				if(String(error.message).indexOf("showContactDetailsInWindow"))
//					trace("showContactDetailsInWindow is not supported on this platform");
//				else
//					throw new Error(error.message,error.errorID);
//			}
//		}
//		public function canclePickContact():void
//		{
//			try{
//				context.call("pickContact","finish");
//			}catch(error:Error){
//				if(String(error.message).indexOf("pickContact"))
//					trace("pickContact is not supported on this platform");
//			}
//		}
//		
//		/**
//		 * checks if the user blocked access to address book for this app
//		 */
//		public function hasPermission():Boolean
//		{  
//			return context.call("hasPermission") as Boolean;
//		}
//
//		private var _callback:Function;
//
//
//		/**
//		 * Gets Details of a Contact.
//		 *
//		 * @param callback:  function( detailedContact:Object ) :void
//		 * 
//		 */	
//		public function getContactDetails(callback:Function, recordId:int):void
//		{  
//			this._callback = callback;
//			context.call("getContactDetails",recordId);
//		}
//
//		
//		public function dispose():void{
//			if(context){
//				context.removeEventListener(StatusEvent.STATUS, onStatus);
//				context.dispose();
//			}
//		}
//		
//		/**
//		 *removes contact with specified recordId 
//		 * @param recordId record identifier, as set in AddressBook on the device
//		 * @return true if contact was removed, false if not found
//		 * 
//		 */		
//		public function removeContact(recordId:int):Boolean
//		{
//			return context.call("removeContact",recordId) as Boolean;
//		}
//		/**
//		 * Whether the ContactEditor is available on the device (true);<br>otherwise false
//		 */
//		public static function get isSupported():Boolean{
//			if(!_set){// checks if a value was set before
//				try{
//					_set = true;
//						var _context:ExtensionContext = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
//						_isSupp = _context.call("contactEditorIsSupported");
//						_context.dispose();
//				}catch(e:Error){
//					trace(e.message,e.errorID);
//					return _isSupp;
//				}
//			}	
//			return _isSupp;
//
//		}
//
//		protected function onStatus(event:StatusEvent):void
//		{
//			var callback:Function = _callback;
//			var fromNativeExtension:Object;
//			if (event.code == ContactEditorEvent.SIMPLE_CONTACTS_READY)
//			{
//				if (callback != null)
//				{
//					_callback = null;
//					fromNativeExtension = context.call("retrieveSimpleContacts");
//					callback( fromNativeExtension as Array);
//				}
//			}
//			else if (event.code == ContactEditorEvent.DETAILED_CONTACT_READY)
//			{
//				if (callback != null)
//				{
//					_callback = null;
//					fromNativeExtension = context.call("retrieveDetailedContact");
//					callback(fromNativeExtension);
//				}
//			}
//			else if(event.code==ContactEditorEvent.CONTACT_SELECTED)
//			{
//				this.dispatchEvent(new ContactEditorEvent(ContactEditorEvent.CONTACT_SELECTED,event.level));
//			}
//			else if(hasEventListener(StatusEvent.STATUS))
//			{
//				this.dispatchEvent(event.clone());
//			}
//			else {
//				trace(event.type+"   "+event.code+"  "+event.level);
//			}
//		}

	}
}





