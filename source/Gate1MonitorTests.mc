import Toybox.Test;
import Toybox.Lang;
import Toybox.Activity;

(:test)
function testStateObservationRequiresManualStopAndAutoPause(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();

    monitor.noteTimerState(Activity.TIMER_STATE_STOPPED);
    Test.assertEqual(0, monitor.getObservationMask() & 0x04);

    monitor.noteTimerState(Activity.TIMER_STATE_PAUSED);
    Test.assertEqual(0x04, monitor.getObservationMask() & 0x04);

    return true;
}

(:test)
function testEighteenStoppedCallbacksSetCallbackObservation(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();

    for (var i = 0; i < 17; i++) {
        monitor.noteCallback(i * 1000, true);
    }
    Test.assertEqual(0, monitor.getObservationMask() & 0x01);

    monitor.noteCallback(17000, true);
    Test.assertEqual(0x01, monitor.getObservationMask() & 0x01);
    Test.assertEqual(18, monitor.getStoppedCallbackCount());
    Test.assertEqual(1000, monitor.getMaximumCallbackGap());

    return true;
}

(:test)
function testVibrationAttemptIsObservationNotPhysicalPass(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();

    Test.assertEqual(0, monitor.getObservationMask() & 0x08);
    monitor.noteVibrationAttempt();
    Test.assertEqual(0x08, monitor.getObservationMask() & 0x08);

    return true;
}

(:test)
function testDistanceUsesScaledCoordinatesWithoutLocationAllocation(logger as Test.Logger) as Boolean {
    var distance = PauseGeo.distanceMeters(0, 0, 0, 549);

    Test.assert(distance > 6.0);
    Test.assert(distance < 6.2);

    return true;
}

(:test)
function testSixSecondsAndSixMetersSetExactTupleObservation(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();

    for (var i = 0; i <= 6; i++) {
        monitor.noteMovementSample(
            i * 1000,
            1500,
            Toybox.Position.QUALITY_GOOD,
            0,
            i * 92,
            true,
            true
        );
    }

    Test.assertEqual(0x02, monitor.getObservationMask() & 0x02);
    return true;
}

(:test)
function testMemoryObservationClearsAboveTwentyFourKilobytes(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();

    monitor.noteMemorySample(24576);
    Test.assertEqual(0x20, monitor.getObservationMask() & 0x20);

    monitor.noteMemorySample(24577);
    Test.assertEqual(0, monitor.getObservationMask() & 0x20);
    Test.assertEqual(24577, monitor.getMaximumUsedMemory());

    return true;
}

(:test)
function testPersistenceObservationTracksLatestCheckpoint(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();

    monitor.notePersistence(true);
    Test.assertEqual(0x40, monitor.getObservationMask() & 0x40);

    monitor.notePersistence(false);
    Test.assertEqual(0, monitor.getObservationMask() & 0x40);

    return true;
}

(:test)
function testFiveMinuteContinuousStoppedCallbacksSetLifecycleObservation(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();

    for (var second = 0; second <= 300; second++) {
        monitor.noteCallback(second * 1000, true);
    }

    Test.assertEqual(0x10, monitor.getObservationMask() & 0x10);
    return true;
}

(:test)
function testLateStoppedCallbackRevokesContinuityObservation(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();

    for (var i = 0; i < 18; i++) {
        monitor.noteCallback(i * 1000, true);
    }
    Test.assertEqual(0x01, monitor.getObservationMask() & 0x01);

    monitor.noteCallback(20001, true);
    Test.assertEqual(0, monitor.getObservationMask() & 0x01);

    return true;
}

(:test)
function testMissingTelemetryInterruptsMovementCandidate(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();

    for (var i = 0; i <= 3; i++) {
        monitor.noteMovementSample(i * 1000, 1500, Toybox.Position.QUALITY_GOOD, 0, i * 92, true, true);
    }
    monitor.noteMovementSample(4000, null, null, null, null, true, true);
    monitor.noteMovementSample(5000, 1500, Toybox.Position.QUALITY_GOOD, 0, 460, true, true);
    monitor.noteMovementSample(6000, 1500, Toybox.Position.QUALITY_GOOD, 0, 552, true, true);

    Test.assertEqual(0, monitor.getObservationMask() & 0x02);
    return true;
}

(:test)
function testThreeIdenticalTuplesInterruptMovementCandidate(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();

    monitor.noteMovementSample(0, 1500, Toybox.Position.QUALITY_GOOD, 0, 0, true, true);
    monitor.noteMovementSample(1000, 1500, Toybox.Position.QUALITY_GOOD, 0, 0, true, true);
    monitor.noteMovementSample(2000, 1500, Toybox.Position.QUALITY_GOOD, 0, 0, true, true);
    monitor.noteMovementSample(3000, 1500, Toybox.Position.QUALITY_GOOD, 0, 276, true, true);
    monitor.noteMovementSample(4000, 1500, Toybox.Position.QUALITY_GOOD, 0, 368, true, true);
    monitor.noteMovementSample(5000, 1500, Toybox.Position.QUALITY_GOOD, 0, 460, true, true);
    monitor.noteMovementSample(6000, 1500, Toybox.Position.QUALITY_GOOD, 0, 552, true, true);

    Test.assertEqual(0, monitor.getObservationMask() & 0x02);
    return true;
}

(:test)
function testSubSixMeterWindowCannotQualifyLate(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();
    var shouldRemind = false;

    for (var i = 0; i <= 6; i++) {
        shouldRemind = monitor.noteMovementSample(
            i * 1000,
            1500,
            Toybox.Position.QUALITY_GOOD,
            0,
            i * 88,
            true,
            true
        ) || shouldRemind;
    }
    Test.assertEqual(0, monitor.getObservationMask() & 0x02);

    shouldRemind = monitor.noteMovementSample(
        7000,
        1500,
        Toybox.Position.QUALITY_GOOD,
        0,
        620,
        true,
        true
    ) || shouldRemind;
    Test.assertEqual(0, monitor.getObservationMask() & 0x02);
    Test.assertEqual(false, shouldRemind);

    return true;
}

(:test)
function testQualifyingStoppedMovementRequestsReminder(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();
    var shouldRemind = false;

    for (var second = 0; second <= 6; second++) {
        shouldRemind = monitor.noteMovementSample(
            second * 1000,
            1500,
            Toybox.Position.QUALITY_GOOD,
            0,
            second * 92,
            true,
            true
        ) || shouldRemind;
    }

    Test.assertEqual(true, shouldRemind);
    return true;
}

(:test)
function testStoppedMovementRequestsOnlyOneReminderPerPause(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();
    var reminderCount = 0;

    for (var second = 0; second <= 13; second++) {
        monitor.noteCallback(second * 1000, true);
        if (monitor.noteMovementSample(
            second * 1000,
            1500,
            Toybox.Position.QUALITY_GOOD,
            0,
            second * 92,
            true,
            true
        )) {
            reminderCount++;
        }
    }

    Test.assertEqual(1, reminderCount);
    return true;
}

(:test)
function testReminderRearmsAfterActivityResumes(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();
    var reminderCount = 0;

    for (var firstSecond = 0; firstSecond <= 6; firstSecond++) {
        monitor.noteCallback(firstSecond * 1000, true);
        if (monitor.noteMovementSample(
            firstSecond * 1000,
            1500,
            Toybox.Position.QUALITY_GOOD,
            0,
            firstSecond * 92,
            true,
            true
        )) {
            reminderCount++;
        }
    }

    monitor.noteTimerState(Activity.TIMER_STATE_ON);

    for (var secondSecond = 0; secondSecond <= 6; secondSecond++) {
        var nowMs = 8000 + (secondSecond * 1000);
        monitor.noteCallback(nowMs, true);
        if (monitor.noteMovementSample(
            nowMs,
            1500,
            Toybox.Position.QUALITY_GOOD,
            1000,
            secondSecond * 92,
            true,
            true
        )) {
            reminderCount++;
        }
    }

    Test.assertEqual(2, reminderCount);
    return true;
}

(:test)
function testAutoPauseMovementNeverRequestsReminder(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();
    var shouldRemind = false;

    for (var second = 0; second <= 10; second++) {
        monitor.noteCallback(second * 1000, false);
        shouldRemind = monitor.noteMovementSample(
            second * 1000,
            2000,
            Toybox.Position.QUALITY_GOOD,
            0,
            second * 120,
            false,
            true
        ) || shouldRemind;
    }

    Test.assertEqual(false, shouldRemind);
    return true;
}

(:test)
function testMissingStoppedSampleDoesNotRearmReminder(logger as Test.Logger) as Boolean {
    var monitor = new Gate1Monitor();
    var reminderCount = 0;

    for (var firstSecond = 0; firstSecond <= 6; firstSecond++) {
        monitor.noteCallback(firstSecond * 1000, true);
        if (monitor.noteMovementSample(
            firstSecond * 1000,
            1500,
            Toybox.Position.QUALITY_GOOD,
            0,
            firstSecond * 92,
            true,
            true
        )) {
            reminderCount++;
        }
    }

    monitor.noteCallback(7000, false);

    for (var secondSecond = 0; secondSecond <= 6; secondSecond++) {
        var nowMs = 8000 + (secondSecond * 1000);
        monitor.noteCallback(nowMs, true);
        if (monitor.noteMovementSample(
            nowMs,
            1500,
            Toybox.Position.QUALITY_GOOD,
            1000,
            secondSecond * 92,
            true,
            true
        )) {
            reminderCount++;
        }
    }

    Test.assertEqual(1, reminderCount);
    return true;
}
