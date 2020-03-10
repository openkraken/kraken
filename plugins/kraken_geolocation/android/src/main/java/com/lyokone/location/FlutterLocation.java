package com.lyokone.location;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.location.Location;
import android.location.LocationManager;
import android.location.OnNmeaMessageListener;
import android.os.Build;
import android.os.Looper;
import android.util.Log;

import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;

import java.util.HashMap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

class FlutterLocation
        implements PluginRegistry.RequestPermissionsResultListener, PluginRegistry.ActivityResultListener {
    private static final String TAG = "FlutterLocation";

    private final Context applicationContext;

    @Nullable
    private Activity activity;

    private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;
    private static final int REQUEST_CHECK_SETTINGS = 0x1;

    private static final int GPS_ENABLE_REQUEST = 0x1001;

    public FusedLocationProviderClient mFusedLocationClient;
    private SettingsClient mSettingsClient;
    private static LocationRequest mLocationRequest;
    private LocationSettingsRequest mLocationSettingsRequest;
    public LocationCallback mLocationCallback;

    @TargetApi(Build.VERSION_CODES.N)
    private OnNmeaMessageListener mMessageListener;

    private Double mLastMslAltitude;

    // Parameters of the request
    private static long updateIntervalMilliseconds = 5000;
    private static long fastestUpdateIntervalMilliseconds = updateIntervalMilliseconds / 2;
    private static Integer locationAccuracy = LocationRequest.PRIORITY_HIGH_ACCURACY;
    private static float distanceFilter = 0f;

    public EventSink events;

    // Store result until a permission check is resolved
    public Result result;

    // Store result until a location is getting resolved
    public Result getLocationResult;

    private int locationPermissionState;

    private boolean waitingForPermission = false;
    private LocationManager locationManager;

    public HashMap<Integer, Integer> mapFlutterAccuracy = new HashMap<Integer, Integer>() {
        {
            put(0, LocationRequest.PRIORITY_NO_POWER);
            put(1, LocationRequest.PRIORITY_LOW_POWER);
            put(2, LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);
            put(3, LocationRequest.PRIORITY_HIGH_ACCURACY);
            put(4, LocationRequest.PRIORITY_HIGH_ACCURACY);
        }
    };

    FlutterLocation(Context applicationContext, @Nullable Activity activity) {
        this.applicationContext = applicationContext;
        this.activity = activity;
    }

    void setActivity(@Nullable Activity activity) {
        this.activity = activity;
        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(activity);
        mSettingsClient = LocationServices.getSettingsClient(activity);
        locationManager = (LocationManager) activity.getSystemService(Context.LOCATION_SERVICE);

        createLocationCallback();
        createLocationRequest();
        buildLocationSettingsRequest();
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == REQUEST_PERMISSIONS_REQUEST_CODE && permissions.length == 1
                && permissions[0].equals(Manifest.permission.ACCESS_FINE_LOCATION)) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Checks if this permission was automatically triggered by a location request
                if (getLocationResult != null || events != null) {
                    startRequestingLocation();
                }
                if (result != null) {
                    result.success(1);
                    result = null;
                }
            } else {
                if (!shouldShowRequestPermissionRationale()) {
                    if (getLocationResult != null) {
                        getLocationResult.error("PERMISSION_DENIED_NEVER_ASK",
                                "Location permission denied forever- please open app settings", null);
                        getLocationResult = null;
                    }
                    if (events != null) {
                        events.error("PERMISSION_DENIED_NEVER_ASK",
                                "Location permission denied forever - please open app settings", null);
                        events = null;
                    }
                    if (result != null) {
                        result.success(2);
                        result = null;
                    }

                } else {
                    if (getLocationResult != null) {
                        getLocationResult.error("PERMISSION_DENIED", "Location permission denied", null);
                        getLocationResult = null;
                    }
                    if (events != null) {
                        events.error("PERMISSION_DENIED", "Location permission denied", null);
                        events = null;
                    }
                    if (result != null) {
                        result.success(0);
                        result = null;
                    }

                }
            }
            return true;
        }
        return false;

    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (result == null) {
            return false;
        }
        switch (requestCode) {
            case GPS_ENABLE_REQUEST:
                if (resultCode == Activity.RESULT_OK) {
                    result.success(1);
                } else {
                    result.success(0);
                }
                break;
            case REQUEST_CHECK_SETTINGS:
                if (resultCode == Activity.RESULT_OK) {
                    startRequestingLocation();
                    return true;
                }

                result.error("SERVICE_STATUS_DISABLED", "Failed to get location. Location services disabled", null);
                return false;
            default:
                return false;
        }
        return true;
    }

    public void changeSettings(Integer locationAccuracy, Long updateIntervalMilliseconds,
            Long fastestUpdateIntervalMilliseconds, Float distanceFilter) {
        this.locationAccuracy = locationAccuracy;
        this.updateIntervalMilliseconds = updateIntervalMilliseconds;
        this.fastestUpdateIntervalMilliseconds = fastestUpdateIntervalMilliseconds;
        this.distanceFilter = distanceFilter;

        createLocationCallback();
        createLocationRequest();
        buildLocationSettingsRequest();
    }

    /**
     * Creates a callback for receiving location events.
     */
    private void createLocationCallback() {
        mLocationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                super.onLocationResult(locationResult);
                Location location = locationResult.getLastLocation();
                HashMap<String, Double> loc = new HashMap<>();
                loc.put("latitude", location.getLatitude());
                loc.put("longitude", location.getLongitude());
                loc.put("accuracy", (double) location.getAccuracy());

                // Using NMEA Data to get MSL level altitude
                if (mLastMslAltitude == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
                    loc.put("altitude", location.getAltitude());
                } else {
                    loc.put("altitude", mLastMslAltitude);
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    loc.put("altitude_accuracy", (double)location.getVerticalAccuracyMeters());
                } else  {
                    loc.put("altitude_accuracy", 0.0);
                }

                loc.put("speed", (double) location.getSpeed());
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    loc.put("speed_accuracy", (double) location.getSpeedAccuracyMetersPerSecond());
                }
                loc.put("heading", (double) location.getBearing());
                loc.put("time", (double) location.getTime());

                if (getLocationResult != null) {
                    getLocationResult.success(loc);
                    getLocationResult = null;
                }
                if (events != null) {
                    events.success(loc);
                } else {
                    mFusedLocationClient.removeLocationUpdates(mLocationCallback);
                }
            }
        };

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            mMessageListener = new OnNmeaMessageListener() {
                @Override
                public void onNmeaMessage(String message, long timestamp) {
                    if (message.startsWith("$")) {
                        String[] tokens = message.split(",");
                        String type = tokens[0];

                        // Parse altitude above sea level, Detailed description of NMEA string here
                        // http://aprs.gids.nl/nmea/#gga
                        if (type.startsWith("$GPGGA") && tokens.length > 9) {
                            if (!tokens[9].isEmpty()) {
                                mLastMslAltitude = Double.parseDouble(tokens[9]);
                            }
                        }
                    }
                }
            };
        }
    }

    /**
     * Sets up the location request. Android has two location request settings:
     */
    private void createLocationRequest() {
        this.mLocationRequest = LocationRequest.create();

        this.mLocationRequest.setInterval(this.updateIntervalMilliseconds);
        this.mLocationRequest.setFastestInterval(this.fastestUpdateIntervalMilliseconds);
        this.mLocationRequest.setPriority(this.locationAccuracy);
        this.mLocationRequest.setSmallestDisplacement(this.distanceFilter);
    }

    /**
     * Uses a
     * {@link com.google.android.gms.location.LocationSettingsRequest.Builder} to
     * build a {@link com.google.android.gms.location.LocationSettingsRequest} that
     * is used for checking if a device has the needed location settings.
     */
    private void buildLocationSettingsRequest() {
        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
        builder.addLocationRequest(mLocationRequest);
        mLocationSettingsRequest = builder.build();
    }

    /**
     * Return the current state of the permissions needed.
     */
    public boolean checkPermissions() {
        this.locationPermissionState = ActivityCompat.checkSelfPermission(activity,
                Manifest.permission.ACCESS_FINE_LOCATION);
        return this.locationPermissionState == PackageManager.PERMISSION_GRANTED;
    }

    public void requestPermissions() {
        if (checkPermissions()) {
            result.success(1);
            return;
        }
        ActivityCompat.requestPermissions(activity, new String[] { Manifest.permission.ACCESS_FINE_LOCATION },
                REQUEST_PERMISSIONS_REQUEST_CODE);
    }

    public boolean shouldShowRequestPermissionRationale() {
        return ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.ACCESS_FINE_LOCATION);
    }

    public boolean checkServiceEnabled(final Result result) {
        boolean gps_enabled = false;
        boolean network_enabled = false;

        try {
            gps_enabled = this.locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
            network_enabled = this.locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
        } catch (Exception ex) {
            result.error("SERVICE_STATUS_ERROR", "Location service status couldn't be determined", null);
            return false;
        }
        if (gps_enabled || network_enabled) {
            if (result != null) {
                result.success(1);
            }
            return true;

        } else {
            if (result != null) {
                result.success(0);
            }
            return false;
        }
    }

    public void requestService(final Result result) {
        if (this.checkServiceEnabled(null)) {
            result.success(1);
            return;
        }
        this.result = result;
        mSettingsClient.checkLocationSettings(mLocationSettingsRequest).addOnFailureListener(activity,
                new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        if (e instanceof ResolvableApiException) {
                            ResolvableApiException rae = (ResolvableApiException) e;
                            int statusCode = rae.getStatusCode();
                            switch (statusCode) {
                                case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                                    try {
                                        // Show the dialog by calling startResolutionForResult(), and check the
                                        // result in onActivityResult().
                                        rae.startResolutionForResult(activity, GPS_ENABLE_REQUEST);
                                    } catch (IntentSender.SendIntentException sie) {
                                        result.error("SERVICE_STATUS_ERROR", "Could not resolve location request",
                                                null);
                                    }
                                    break;
                                case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                                    result.error("SERVICE_STATUS_DISABLED",
                                            "Failed to get location. Location services disabled", null);
                                    break;
                            }
                        } else {
                            // This should not happen according to Android documentation but it has been
                            // observed on some phones.
                            result.error("SERVICE_STATUS_ERROR", "Unexpected error type received", null);
                        }
                    }
                });
    }

    public void startRequestingLocation() {
        mSettingsClient.checkLocationSettings(mLocationSettingsRequest)
                .addOnSuccessListener(activity, new OnSuccessListener<LocationSettingsResponse>() {
                    @Override
                    public void onSuccess(LocationSettingsResponse locationSettingsResponse) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            locationManager.addNmeaListener(mMessageListener);
                        }
                        mFusedLocationClient.requestLocationUpdates(mLocationRequest, mLocationCallback,
                                Looper.myLooper());
                    }
                }).addOnFailureListener(activity, new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        if (e instanceof ResolvableApiException) {
                            ResolvableApiException rae = (ResolvableApiException) e;
                            int statusCode = rae.getStatusCode();
                            switch (statusCode) {
                                case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                                    try {
                                        // Show the dialog by calling startResolutionForResult(), and check the
                                        // result in onActivityResult().
                                        rae.startResolutionForResult(activity, REQUEST_CHECK_SETTINGS);
                                    } catch (IntentSender.SendIntentException sie) {
                                        Log.i(TAG, "PendingIntent unable to execute request.");
                                    }
                                    break;
                                case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                                    String errorMessage = "Location settings are inadequate, and cannot be "
                                            + "fixed here. Fix in Settings.";
                                    Log.e(TAG, errorMessage);
                            }
                        } else {
                            // This should not happen according to Android documentation but it has been
                            // observed on some phones.
                            Log.e(TAG, "Unexpected error type received");
                        }
                    }
                });
    }

}
