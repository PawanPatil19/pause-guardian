import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;

module PauseGuardianSession {
    const SUMMARY_KEY = "last_gate1_summary_v1";
    // Single source of truth for the app version. Must match the release tag (v0.1.0-g1) and CHANGELOG.md.
    const BUILD_ID = "0.1.0-g1";

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
        try {
            monitor.noteMemorySample(System.getSystemStats().usedMemory);
            // The stored mask claims 40 because this write is the checkpoint. The live
            // monitor only earns 40 after the read-back below confirms the write.
            var storedMask = monitor.getObservationMask() | 0x40;
            var summary = {
                "version" => 1,
                "build" => BUILD_ID,
                "mask" => storedMask,
                "events" => eventMask,
                "callbacks" => monitor.getStoppedCallbackCount(),
                "maxGap" => monitor.getMaximumCallbackGap(),
                "maxMemory" => monitor.getMaximumUsedMemory()
            };
            Storage.setValue(SUMMARY_KEY, summary);

            // A failed read-back leaves 40 in whatever was stored, on purpose: the next
            // successful checkpoint overwrites it, and the live mask shows the failure now.
            var readback = Storage.getValue(SUMMARY_KEY) as Dictionary?;
            monitor.notePersistence(
                (readback != null) &&
                (readback["version"] == 1) &&
                BUILD_ID.equals(readback["build"]) &&
                (readback["mask"] == storedMask)
            );
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
