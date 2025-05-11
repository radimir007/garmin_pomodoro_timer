import Toybox.Lang;
import Toybox.WatchUi;

class PomodoroTimerDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new PomodoroTimerMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}