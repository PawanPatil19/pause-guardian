import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;

module PauseGuardianSession {
    const SUMMARY_KEY = "last_gate1_summary_v1";
    const BUILD_ID = "g1-0.1.0";

    var monitor = new Gate1Monitor();
    var eventMask = 0;
    var lastMask = 0;
    var showLastStartedAt = 0;
    var dirty = false;

    public function load() as Void {
        dirty = false;
        showLastStartedAt = System.getTimer();
        try {
            var stored = Storage.getValue(SUMMARY_KEY) as Dictionary?;
            if (stored != null) {
                var storedMask = stored["mask"];
                if (storedMask != null) {
                    lastMask = storedMask;
                }
            }
        } catch (exception) {
            lastMask = 0;
        }
    }

    public function checkpoint() as Void {
        if (!dirty) {
            return;
        }
        monitor.notePersistence(true);
        try {
            var summary = {
                "version" => 1,
                "build" => BUILD_ID,
                "mask" => monitor.getObservationMask(),
                "events" => eventMask,
                "callbacks" => monitor.getStoppedCallbackCount(),
                "maxGap" => monitor.getMaximumCallbackGap(),
                "maxMemory" => monitor.getMaximumUsedMemory()
            };
            monitor.noteMemorySample(System.getSystemStats().usedMemory);
            summary["maxMemory"] = monitor.getMaximumUsedMemory();
            summary["mask"] = monitor.getObservationMask();
            Storage.setValue(SUMMARY_KEY, summary);

            var readback = Storage.getValue(SUMMARY_KEY) as Dictionary?;
            if ((readback == null) ||
                (readback["version"] != 1) ||
                (readback["build"] != BUILD_ID)) {
                monitor.notePersistence(false);
            }
        } catch (exception) {
            monitor.notePersistence(false);
        }
    }

    public function reset() as Void {
        checkpoint();
        lastMask = monitor.getObservationMask();
        showLastStartedAt = System.getTimer();
        monitor = new Gate1Monitor();
        eventMask = 0;
        dirty = false;
    }

    public function markDirty() as Void {
        dirty = true;
    }

    public function displayText() as String {
        var showLastElapsed = System.getTimer() - showLastStartedAt;
        if ((showLastElapsed >= 0) && (showLastElapsed <= 10000) && (lastMask != 0)) {
            return "L" + lastMask.format("%02X");
        }
        return "O" + monitor.getObservationMask().format("%02X");
    }
}
