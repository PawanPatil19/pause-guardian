import Toybox.Math;
import Toybox.Lang;

module PauseGeo {
    const RADIANS_PER_E7 = 0.0000000017453292519943295d;
    const PI = 3.141592653589793d;
    const TWO_PI = 6.283185307179586d;
    const EARTH_RADIUS_METERS = 6371000.0d;

    public function distanceMeters(lat1E7 as Number, lon1E7 as Number, lat2E7 as Number, lon2E7 as Number) {
        var lat1 = lat1E7.toDouble() * RADIANS_PER_E7;
        var lat2 = lat2E7.toDouble() * RADIANS_PER_E7;
        var deltaLat = lat2 - lat1;
        var deltaLon = (lon2E7.toDouble() - lon1E7.toDouble()) * RADIANS_PER_E7;

        if (deltaLon > PI) {
            deltaLon -= TWO_PI;
        } else if (deltaLon < -PI) {
            deltaLon += TWO_PI;
        }

        var x = deltaLon * Math.cos((lat1 + lat2) / 2.0d);
        return EARTH_RADIUS_METERS * Math.sqrt((x * x) + (deltaLat * deltaLat));
    }
}
