import Toybox.Lang;
import Toybox.Activity;
import Toybox.Position;

class Gate1Monitor {
    private var _sawStopped as Boolean;
    private var _sawPaused as Boolean;
    private var _observationMask as Number;
    private var _callbackEpisodeActive as Boolean;
    private var _stoppedCallbackCount as Number;
    private var _lastCallbackAt as Number;
    private var _maximumCallbackGap as Number;
    private var _callbackStartedAt as Number;
    private var _movementCandidateActive as Boolean;
    private var _movementStartedAt as Number;
    private var _movementLastAt as Number;
    private var _movementStartLatE7 as Number;
    private var _movementStartLonE7 as Number;
    private var _maximumUsedMemory as Number;
    private var _hasPreviousTuple as Boolean;
    private var _previousSpeed as Number;
    private var _previousLatE7 as Number;
    private var _previousLonE7 as Number;
    private var _identicalTupleCount as Number;
    private var _movementReminderSent as Boolean;

    public function initialize() {
        _sawStopped = false;
        _sawPaused = false;
        _observationMask = 0;
        _callbackEpisodeActive = false;
        _stoppedCallbackCount = 0;
        _lastCallbackAt = 0;
        _maximumCallbackGap = 0;
        _callbackStartedAt = 0;
        _movementCandidateActive = false;
        _movementStartedAt = 0;
        _movementLastAt = 0;
        _movementStartLatE7 = 0;
        _movementStartLonE7 = 0;
        _maximumUsedMemory = 0;
        _hasPreviousTuple = false;
        _previousSpeed = 0;
        _previousLatE7 = 0;
        _previousLonE7 = 0;
        _identicalTupleCount = 0;
        _movementReminderSent = false;
    }

    public function noteTimerState(timerState as Number) as Void {
        if (timerState == Activity.TIMER_STATE_STOPPED) {
            _sawStopped = true;
        } else if (timerState == Activity.TIMER_STATE_PAUSED) {
            _sawPaused = true;
        }

        if (timerState != Activity.TIMER_STATE_STOPPED) {
            rearmReminder();
        }

        if (_sawStopped && _sawPaused) {
            _observationMask |= 0x04;
        }
    }

    public function getObservationMask() as Number {
        return _observationMask;
    }

    public function rearmReminder() as Void {
        _movementReminderSent = false;
    }

    public function noteCallback(nowMs as Number, isStopped as Boolean) as Void {
        if (!isStopped) {
            _callbackEpisodeActive = false;
            return;
        }

        if (!_callbackEpisodeActive) {
            _callbackEpisodeActive = true;
            _stoppedCallbackCount = 1;
            _callbackStartedAt = nowMs;
            _lastCallbackAt = nowMs;
            _maximumCallbackGap = 0;
            return;
        }

        var gap = nowMs - _lastCallbackAt;
        _lastCallbackAt = nowMs;
        if (gap < 0) {
            _stoppedCallbackCount = 1;
            _callbackStartedAt = nowMs;
            _maximumCallbackGap = 0;
            _observationMask &= ~(0x01 | 0x10);
            return;
        }
        _stoppedCallbackCount++;
        if (gap > _maximumCallbackGap) {
            _maximumCallbackGap = gap;
        }
        if (gap > 2000) {
            _observationMask &= ~(0x01 | 0x10);
        }

        if ((_stoppedCallbackCount >= 18) && (_maximumCallbackGap <= 2000)) {
            _observationMask |= 0x01;
        }
        if ((nowMs - _callbackStartedAt >= 300000) &&
            (_maximumCallbackGap <= 2000)) {
            _observationMask |= 0x10;
        }
    }

    public function getStoppedCallbackCount() as Number {
        return _stoppedCallbackCount;
    }

    public function getMaximumCallbackGap() as Number {
        return _maximumCallbackGap;
    }

    public function noteVibrationAttempt() as Void {
        _observationMask |= 0x08;
    }

    public function noteMovementSample(
        nowMs as Number,
        speedMmPerSecond as Number?,
        gpsQuality as Number?,
        latE7 as Number?,
        lonE7 as Number?,
        isStopped as Boolean,
        isRunningProfile as Boolean
    ) as Boolean {
        if ((speedMmPerSecond == null) || (gpsQuality == null) ||
            (latE7 == null) || (lonE7 == null)) {
            _movementCandidateActive = false;
            _hasPreviousTuple = false;
            _identicalTupleCount = 0;
            return false;
        }

        var usableGps = (gpsQuality == Position.QUALITY_USABLE) ||
                        (gpsQuality == Position.QUALITY_GOOD);
        var valid = isStopped && isRunningProfile && usableGps &&
                    (speedMmPerSecond >= 1400);

        if (!valid) {
            _movementCandidateActive = false;
            _hasPreviousTuple = false;
            _identicalTupleCount = 0;
            return false;
        }

        if (_hasPreviousTuple &&
            (speedMmPerSecond == _previousSpeed) &&
            (latE7 == _previousLatE7) &&
            (lonE7 == _previousLonE7)) {
            _identicalTupleCount++;
        } else {
            _identicalTupleCount = 1;
        }
        _hasPreviousTuple = true;
        _previousSpeed = speedMmPerSecond;
        _previousLatE7 = latE7;
        _previousLonE7 = lonE7;

        if (_identicalTupleCount >= 3) {
            _movementCandidateActive = false;
            return false;
        }

        if (!_movementCandidateActive ||
            (nowMs < _movementLastAt) ||
            (nowMs - _movementLastAt > 2000)) {
            _movementCandidateActive = true;
            _movementStartedAt = nowMs;
            _movementLastAt = nowMs;
            _movementStartLatE7 = latE7;
            _movementStartLonE7 = lonE7;
            return false;
        }

        _movementLastAt = nowMs;
        if (nowMs - _movementStartedAt >= 6000) {
            if (PauseGeo.distanceMeters(
                _movementStartLatE7,
                _movementStartLonE7,
                latE7,
                lonE7
            ) >= 6.0) {
                _observationMask |= 0x02;
                _movementCandidateActive = false;
                if (!_movementReminderSent) {
                    _movementReminderSent = true;
                    return true;
                }
                return false;
            }
            _movementCandidateActive = false;
        }

        return false;
    }

    public function noteMemorySample(usedMemory as Number) as Void {
        if (usedMemory > _maximumUsedMemory) {
            _maximumUsedMemory = usedMemory;
        }

        if (_maximumUsedMemory <= 24576) {
            _observationMask |= 0x20;
        } else {
            _observationMask &= ~0x20;
        }
    }

    public function getMaximumUsedMemory() as Number {
        return _maximumUsedMemory;
    }

    public function notePersistence(succeeded as Boolean) as Void {
        if (succeeded) {
            _observationMask |= 0x40;
        } else {
            _observationMask &= ~0x40;
        }
    }
}
