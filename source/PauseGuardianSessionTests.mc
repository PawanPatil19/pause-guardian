import Toybox.Test;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application.Storage;

// PauseGuardianSession is a module with global state, so every test starts from a clean slate
// and removes its stored summary when done. (:debug) keeps this helper out of release builds
// without the test runner treating it as a test.
(:debug)
function resetSessionForTest() as Void {
    Storage.deleteValue(PauseGuardianSession.SUMMARY_KEY);
    PauseGuardianSession.monitor = new Gate1Monitor();
    PauseGuardianSession.eventMask = 0;
    PauseGuardianSession.lastMask = 0;
    PauseGuardianSession.showLastStartedAt = System.getTimer() - 20000;
    PauseGuardianSession.dirty = false;
}

(:test)
function testCheckpointSkipsWriteWhenNothingChanged(logger as Test.Logger) as Boolean {
    resetSessionForTest();

    PauseGuardianSession.checkpoint();

    Test.assert(Storage.getValue(PauseGuardianSession.SUMMARY_KEY) == null);
    Test.assertEqual(0, PauseGuardianSession.monitor.getObservationMask() & 0x40);
    resetSessionForTest();
    return true;
}

(:test)
function testCheckpointStoresSummaryAndEarnsPersistenceAfterReadback(logger as Test.Logger) as Boolean {
    resetSessionForTest();
    PauseGuardianSession.monitor.noteVibrationAttempt();
    PauseGuardianSession.eventMask = 0x02;
    PauseGuardianSession.markDirty();

    PauseGuardianSession.checkpoint();

    var storedValue = Storage.getValue(PauseGuardianSession.SUMMARY_KEY);
    Test.assert(storedValue != null);
    var stored = storedValue as Dictionary;
    Test.assertEqual(1, stored["version"]);
    Test.assertEqual(PauseGuardianSession.BUILD_ID, stored["build"]);
    Test.assertEqual(0x02, stored["events"]);
    Test.assertEqual(0x48, (stored["mask"] as Number) & 0x48);
    Test.assertEqual(0x40, PauseGuardianSession.monitor.getObservationMask() & 0x40);
    resetSessionForTest();
    return true;
}

(:test)
function testResetMovesMaskToLastAndStartsFreshMonitor(logger as Test.Logger) as Boolean {
    resetSessionForTest();
    PauseGuardianSession.monitor.noteVibrationAttempt();
    PauseGuardianSession.eventMask = 0x1F;
    PauseGuardianSession.markDirty();

    PauseGuardianSession.reset();

    Test.assertEqual(0x48, PauseGuardianSession.lastMask & 0x48);
    Test.assertEqual(0, PauseGuardianSession.monitor.getObservationMask());
    Test.assertEqual(0, PauseGuardianSession.eventMask);
    Test.assertEqual(false, PauseGuardianSession.dirty);
    resetSessionForTest();
    return true;
}

(:test)
function testDisplayShowsLastMaskOnlyDuringTenSecondWindow(logger as Test.Logger) as Boolean {
    resetSessionForTest();
    PauseGuardianSession.lastMask = 0x49;

    PauseGuardianSession.showLastStartedAt = System.getTimer();
    Test.assertEqual("L49", PauseGuardianSession.displayText());

    PauseGuardianSession.showLastStartedAt = System.getTimer() - 10001;
    Test.assertEqual("O00", PauseGuardianSession.displayText());

    resetSessionForTest();
    return true;
}

(:test)
function testDisplayShowsCurrentMaskWhenNoPreviousSession(logger as Test.Logger) as Boolean {
    resetSessionForTest();
    PauseGuardianSession.showLastStartedAt = System.getTimer();
    PauseGuardianSession.monitor.noteVibrationAttempt();

    Test.assertEqual("O08", PauseGuardianSession.displayText());
    resetSessionForTest();
    return true;
}

(:test)
function testLoadReadsPreviousMaskFromStorage(logger as Test.Logger) as Boolean {
    resetSessionForTest();
    Storage.setValue(PauseGuardianSession.SUMMARY_KEY, {"mask" => 0x41});

    PauseGuardianSession.load();

    Test.assertEqual(0x41, PauseGuardianSession.lastMask);
    Test.assertEqual(false, PauseGuardianSession.dirty);
    resetSessionForTest();
    return true;
}
