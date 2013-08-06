package pl.mateuszmackowiak.nativeANE.contactManager.functions;

import pl.mateuszmackowiak.nativeANE.contactManager.ContactEditorContext;
import android.util.Log;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class RetrieveAllDetails implements FREFunction {

	private static final String TAG = "ContactEditor";
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		Log.d(TAG, "Entering RetrieveAllDetails.call()");
		
		FREArray detailedContacts = ((ContactEditorContext) context).retreiveAllContacts(); 
		
		Log.d(TAG, "Exiting RetrieveAllDetails.call()");
		
		return detailedContacts;
	}

}
