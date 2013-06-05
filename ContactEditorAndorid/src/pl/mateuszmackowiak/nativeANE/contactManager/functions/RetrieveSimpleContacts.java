package pl.mateuszmackowiak.nativeANE.contactManager.functions;

import pl.mateuszmackowiak.nativeANE.contactManager.ContactEditorContext;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class RetrieveSimpleContacts implements FREFunction {

	private static final String TAG = "ContactEditor";
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		Log.d(TAG, "Entering RetrieveSimpleContacts.call()");
		
		FREObject simpleContacts = null;
		
		try {
			int batchStart = args[0].getAsInt();
			int batchLength = args[1].getAsInt();
			simpleContacts = ((ContactEditorContext) context).retrieveContactsSimple(
					batchStart, batchLength);
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		}
		
		Log.d(TAG, "Exiting RetrieveSimpleContacts.call()");
		return simpleContacts;
	}

}
