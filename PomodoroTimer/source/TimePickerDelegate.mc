import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Graphics;

class TimePickerDelegate extends WatchUi.BehaviorDelegate {

    var systemOptions = System.getDeviceSettings();

    var parentMode, parentItem;

    var initValue = Application.Storage.getValue("modes") as Array;
    var wasEdited = false;


    function initialize(mode, item) {
        BehaviorDelegate.initialize();

        parentMode = mode;
        parentItem = item;
    }

    function onKey(keyEvent as KeyEvent) as Boolean {

        switch (keyEvent.getKey()) {
            case KEY_ENTER:
                var modes = Application.Storage.getValue("modes") as Array;
                var additiveText = "";

                if (!parentItem.getId().equals("group")) {
                    additiveText = " min";
                }

                if (wasEdited) {
                    parentItem.setSubLabel(modes[parentMode.getId()][parentItem.getId()].toString() + additiveText);
                }

                WatchUi.popView(WatchUi.SLIDE_RIGHT);

                break;
            case KEY_ESC:
                if (wasEdited) {
                    Application.Storage.setValue("modes", initValue);
                }
                
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                break;
            default:
                break;
        }
        
        WatchUi.requestUpdate();

        return true;
    }

    function onBack() as Boolean {
        if (wasEdited) {
            Application.Storage.setValue("modes", initValue);
        }
        
        WatchUi.popView(WatchUi.SLIDE_RIGHT);

        return true;
    }

    function onTap(clickEvent as ClickEvent) as Boolean {
        
        var locY = clickEvent.getCoordinates()[1];

        if (locY >= 0 && locY <= 200) {
            increase();
        } else if (locY >= systemOptions.screenHeight - 200 && locY <= systemOptions.screenHeight) {
            decrease();
        }

        return true;
    }

    function increase() {
        var modes = Application.Storage.getValue("modes") as Array;

        if (modes[parentMode.getId()][parentItem.getId()] + 1 <= 120) {
            modes[parentMode.getId()][parentItem.getId()] += 1;
            
            Application.Storage.setValue("modes", modes);

            WatchUi.requestUpdate();
        }

        wasEdited = true;
    }

    function decrease() {
        var modes = Application.Storage.getValue("modes");

        if (modes[parentMode.getId()][parentItem.getId()] - 1 > 0) {
            modes[parentMode.getId()][parentItem.getId()] -= 1;

            Application.Storage.setValue("modes", modes);

            WatchUi.requestUpdate();
        }

        wasEdited = true;
    }
}