import Toybox.Application;

class PauseGuardianApp extends Application.AppBase {
    public function initialize() {
        AppBase.initialize();
    }

    public function getInitialView() {
        return [new PauseGuardianField()];
    }

    public function onStart(state) as Void {
        PauseGuardianSession.load();
    }

    public function onStop(state) as Void {
        PauseGuardianSession.checkpoint();
    }
}
