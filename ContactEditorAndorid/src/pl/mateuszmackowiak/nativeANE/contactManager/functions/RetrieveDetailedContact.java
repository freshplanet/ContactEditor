package pl.mateuszmackowiak.nativeANE.contactManager.functions;

import pl.mateuszmackowiak.nativeANE.contactManager.ContactEditorContext;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class RetrieveDetailedContact implements FREFunction {

	private static final String TAG = "[ContactEditor] - RetrieveDetailedContact";
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		Log.d(TAG, "Entering call");
		
		FREObject detailedContact = ((ContactEditorContext) context).retrieveDetailedContact(); 
		
		Log.d(TAG, "Exiting call");
		
		return detailedContact;
	}

}
