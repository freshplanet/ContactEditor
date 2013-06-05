package pl.mateuszmackowiak.nativeANE.contactManager.functions;

import pl.mateuszmackowiak.nativeANE.contactManager.ContactEditorContext;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class GetContactCount implements FREFunction {

	private static final String TAG = "ContactEditor";
	
	@Override
	public FREObject call(FREContext contact, FREObject[] args) {
		Log.d(TAG, "Entering GetContactCount.call()");
		
		((ContactEditorContext) contact).getContactCount();
		
		Log.d(TAG, "Exiting GetContactCount.call()");
		return null;
	}

}
