import Toybox.Lang;
import Toybox.WatchUi;

class PomodoroTimerDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        return true;
    }

    function onTap(clickEvent as ClickEvent) as Boolean {
        
        var coords = clickEvent.getCoordinates();
        var locY = coords[1];

        if (locY >= 0 && locY <= 150) {
            System.println("Mode tapped");
        } else {
            System.println("Start tapped");
        }

        return true;
    }

}