import Toybox.Activity;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class PauseGuardianField extends WatchUi.SimpleDataField {
    private var _eventTimerState as Number;
    private var _vibrationPattern;
    private var _hasSessionStart as Boolean;
    private var _sessionStart as Number;

    public function initialize() {
        SimpleDataField.initialize();
        label = WatchUi.loadResource(Rez.Strings.FieldLabel) as String;
        _eventTimerState = Activity.TIMER_STATE_OFF;
        _vibrationPattern = [
            new Attention.VibeProfile(100, 500),
            new Attention.VibeProfile(0, 250),
            new Attention.VibeProfile(100, 500),
            new Attention.VibeProfile(0, 250),
            new Attention.VibeProfile(100, 500)
        ];
        _hasSessionStart = false;
        _sessionStart = 0;
    }

    public function compute(info as Activity.Info) {
        PauseGuardianSession.markDirty();
        var nowMs = System.getTimer();
        var startTime = info.startTime;
        if (startTime != null) {
            var startValue = startTime.value();
            if (_hasSessionStart && (startValue != _sessionStart)) {
                PauseGuardianSession.reset();
            }
            _hasSessionStart = true;
            _sessionStart = startValue;
        }
        var timerState = info.timerState;
        var hasAuthoritativeState = timerState != null;
        if (timerState == null) {
            timerState = _eventTimerState;
        } else {
            PauseGuardianSession.monitor.noteTimerState(timerState);
        }

        var isStopped = timerState == Activity.TIMER_STATE_STOPPED;
        var qualifyingStopped = isStopped && hasAuthoritativeState;
        PauseGuardianSession.monitor.noteCallback(nowMs, qualifyingStopped);

        var speed = info.currentSpeed;
        var location = info.currentLocation;
        var quality = info.currentLocationAccuracy;
        if ((speed != null) && (location != null) && (quality != null)) {
            var profile = Activity.getProfileInfo();
            var isRunning = (profile != null) && (profile.sport == Activity.SPORT_RUNNING);
            var degrees = location.toDegrees();
            PauseGuardianSession.monitor.noteMovementSample(
                nowMs,
                (speed * 1000.0f).toNumber(),
                quality,
                (degrees[0] * 10000000.0d).toNumber(),
                (degrees[1] * 10000000.0d).toNumber(),
                qualifyingStopped,
                isRunning
            );
        } else {
            PauseGuardianSession.monitor.noteMovementSample(
                nowMs, null, null, null, null, qualifyingStopped, false
            );
        }

        if (PauseGuardianSession.monitor.shouldProbe(nowMs, isStopped)) {
            vibrateProbe();
        }

        var display = PauseGuardianSession.displayText();
        PauseGuardianSession.monitor.noteMemorySample(System.getSystemStats().usedMemory);
        return display;
    }

    public function onTimerStart() as Void {
        PauseGuardianSession.markDirty();
        if (_eventTimerState == Activity.TIMER_STATE_STOPPED) {
            PauseGuardianSession.checkpoint();
        }
        _eventTimerState = Activity.TIMER_STATE_ON;
        PauseGuardianSession.eventMask |= 0x01;
        PauseGuardianSession.monitor.shouldProbe(System.getTimer(), false);
    }

    public function onTimerStop() as Void {
        PauseGuardianSession.markDirty();
        _eventTimerState = Activity.TIMER_STATE_STOPPED;
        PauseGuardianSession.eventMask |= 0x02;
    }

    public function onTimerPause() as Void {
        PauseGuardianSession.markDirty();
        _eventTimerState = Activity.TIMER_STATE_PAUSED;
        PauseGuardianSession.eventMask |= 0x04;
        PauseGuardianSession.monitor.shouldProbe(System.getTimer(), false);
    }

    public function onTimerResume() as Void {
        PauseGuardianSession.markDirty();
        _eventTimerState = Activity.TIMER_STATE_ON;
        PauseGuardianSession.eventMask |= 0x08;
        PauseGuardianSession.checkpoint();
        PauseGuardianSession.monitor.shouldProbe(System.getTimer(), false);
    }

    public function onTimerReset() as Void {
        PauseGuardianSession.markDirty();
        _eventTimerState = Activity.TIMER_STATE_OFF;
        _hasSessionStart = false;
        PauseGuardianSession.eventMask |= 0x10;
        PauseGuardianSession.reset();
    }

    private function vibrateProbe() as Void {
        if (!(Attention has :vibrate)) {
            return;
        }

        try {
            Attention.vibrate(_vibrationPattern);
            PauseGuardianSession.monitor.noteVibrationAttempt();
            PauseGuardianSession.monitor.noteMemorySample(System.getSystemStats().usedMemory);
        } catch (exception) {
            // The observation remains clear; the field must never crash the activity.
        }
    }
}
