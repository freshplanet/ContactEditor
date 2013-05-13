package pl.mllr.extensions.contactEditor
{
	import flash.desktop.DockIcon;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;

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
		 */
		public function getContactCount():void
		{
			_context.call("getContactCount");
		} 
		
		/**
		 * Retrieve contacts (recordId, compositeName) stored in the address book.<br/><br/>
		 * 
		 * For performance optimization, this method allows retrieving the data in batches.  
		 * You can use Adobe Scout to find a good batch size that will not impact your FPS, and 
		 * distribute your batches in several frames.
		 * 
		 * Possible error codes dispatched by the Native Extension:
		 * <ul>
		 * <li>ADDRESS_BOOK_ACCESS_DENIED : Developers should display a message 
		 * asking users to grant access to the AddressBook for the application (iOS Only)</li>
		 * </ul>
		 *  
		 * @param batchStart where should each batch start (zero-indexed).
		 * @param batchLength how many elements should be retrieved this batch.
		 */
		public function getContactsSimple( batchStart:int, batchLength:int ):void
		{
			_context.call("getContactsSimple", batchStart, batchLength);
		}
		
		/**
		 * Retrieve details for a specific contact.<br/><br/>
		 * 
		 * Possible error codes dispatched by the Native Extension:
		 * <ul>
		 * <li>ADDRESS_BOOK_ACCESS_DENIED : Developers should display a message 
		 * asking users to grant access to the AddressBook for the application (iOS Only)</li>
		 * </ul>
		 * 
		 * @param contactRecordId the identifier of a contact in the address book.  
		 * getContactsSimple() should have this data for each contact. 
		 */
		public function getDetailsForContact( contactRecordId:int ):void
		{
			_context.call("getContactDetails",contactRecordId);
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////
		// 	PRIVATE API
		///////////////////////////////////////////////////////////////////////////////////////////
		
		private static const EXTENSION_ID : String = "pl.mllr.extensions.contactEditor";
		
		private static var _instance : ContactEditor;
		
		private var _context : ExtensionContext;
		
		private function onStatus( event:StatusEvent ) : void
		{
			var callback:Function;
			var evt:ContactEditorEvent;
			
			if (event.code == ContactEditorEvent.ADDRESS_BOOK_ACCESS_DENIED)
			{
				evt = new ContactEditorEvent(ContactEditorEvent.ADDRESS_BOOK_ACCESS_DENIED);
				this.dispatchEvent(evt);
			}
			else if (event.code == ContactEditorEvent.NUM_CONTACT_UPDATED)
			{
				evt = new ContactEditorEvent(ContactEditorEvent.NUM_CONTACT_UPDATED,int(event.level));
				this.dispatchEvent(evt)
			}
			else if (event.code == ContactEditorEvent.SIMPLE_CONTACTS_UPDATED)
			{
				var start:int = int( event.level.split("-")[0]);
				var batchLength:int = int( event.level.split("-")[1]);
				var simpleContacts:Array = _context.call("retrieveSimpleContacts", start, batchLength) as Array;
				evt = new ContactEditorEvent(ContactEditorEvent.SIMPLE_CONTACTS_UPDATED,simpleContacts);
				this.dispatchEvent(evt)
			}
			else if (event.code == ContactEditorEvent.DETAILED_CONTACT_UPDATED)
			{
				var contact:Object = _context.call("retrieveDetailedContact") as Object;
				evt = new ContactEditorEvent(ContactEditorEvent.DETAILED_CONTACT_UPDATED,contact);
				this.dispatchEvent(evt)
			}
			else
			{
				trace("[ContactEditor] onStatus: ", event.code, event.level);
			}
		}
	}
}





