package pl.mateuszmackowiak.nativeANE.contactManager.functions;

import pl.mateuszmackowiak.nativeANE.contactManager.ContactEditorContext;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class GetContactCount implements FREFunction {

	private static final String TAG = "[ContactEditor] - GetContactCountFunction";
	
	@Override
	public FREObject call(FREContext contact, FREObject[] args) {
		Log.d(TAG, "Entering call");
		
		((ContactEditorContext) contact).getContactCount();
		
		Log.d(TAG, "Exiting call");
		return null;
	}

}
