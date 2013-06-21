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
		 */
		public function getContactCount( callback:Function ):void
		{
			_contactCountCallback = callback;
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
		public function getContactsSimple( callback:Function, batchStart:int, batchLength:int ):void
		{
			_simpleContactsCallback = callback;
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
		public function getDetailsForContact( callback:Function, contactRecordId:int ):void
		{
			_detailedContactCallback = callback;
			_context.call("getContactDetails",contactRecordId);
		}
		
		/**
		 * callback will be called once with an array of results
		 */
		public function getDetailsForContacts( callback:Function, contactRecords:Vector.<int> ):void
		{
			trace( "[ContactEditor]", "getting contact details for ids ", contactRecords ) ;
			_detailedContactCallback = callback;
			_context.call("getContactsDetails",contactRecords);
		}
		
		/** Removes the callback. */
		public function removeSimpleContactCallback():void
		{
			_simpleContactsCallback = null;
		}
		
		/** Removes the callback. */
		public function removeDetailedContactCallback():void
		{
			_detailedContactCallback = null;
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////
		// 	PRIVATE API
		///////////////////////////////////////////////////////////////////////////////////////////
		
		private static const EXTENSION_ID : String = "pl.mllr.extensions.contactEditor";
		
		private static var _instance : ContactEditor;
		
		private var _context : ExtensionContext;
		
		private var _contactCountCallback:Function;
		private var _simpleContactsCallback:Function;
		private var _detailedContactCallback:Function;
		
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
				if ( _contactCountCallback !== null )
				{
					callback = _contactCountCallback;
					_contactCountCallback = null;
					
					var numContacts:int = int(event.level);
					callback(numContacts);
				}
			}
			else if (event.code == ContactEditorEvent.SIMPLE_CONTACTS_UPDATED)
			{
				trace( "as3 received - simpleContactsUpdated") ;
				if (_simpleContactsCallback !== null)
				{
					var start:int = int( event.level.split("-")[0]);
					var batchLength:int = int( event.level.split("-")[1]);
					var simpleContacts:Array = _context.call("retrieveSimpleContacts", start, batchLength) as Array;
					
					_simpleContactsCallback(simpleContacts);
				}
			}
			else if (event.code == ContactEditorEvent.DETAILED_CONTACT_UPDATED)
			{
				if ( _detailedContactCallback !== null )
				{
					var contact:Object = _context.call("retrieveDetailedContact") as Object;
					_detailedContactCallback(contact);
				}
			}
			else if (event.code == ContactEditorEvent.DETAILED_CONTACTS_UPDATED)
			{
				if ( _detailedContactCallback !== null )
				{
					var contact:Object = _context.call("retrieveAllDetails") as Object;
					_detailedContactCallback(contact);
				}
			}
			else
			{
				trace("[ContactEditor] onStatus: ", event.code, event.level);
			}
		}
	}
}





