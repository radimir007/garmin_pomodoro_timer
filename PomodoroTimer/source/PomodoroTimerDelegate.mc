import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Timer;

// Main delegate

class PomodoroTimerDelegate extends WatchUi.BehaviorDelegate {

    var value = Application.Storage.getValue("modes")[Application.Storage.getValue("chosenMode")]["pomodoro"];

    var vibrationModes = ["Off", "Mild", "Normal", "High", "Strong"];

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        return true;
    }

    function onTap(clickEvent as ClickEvent) as Boolean {

        if (Application.Storage.getValue("isTimerStarted") == true) {
            return false;
        }
        
        var coords = clickEvent.getCoordinates();
        var locY = coords[1];

        if (locY >= 0 && locY <= 150) {

            var modeMenu = new Menu2({
                :title => "Select mode"
            });

            var options = Application.Storage.getValue("modes") as Array;

            for (var i = 0; i < options.size(); i++) {
                 modeMenu.addItem(
                    new MenuItem(
                        options[i]["label"],
                        options[i]["group"] + "x " + options[i]["pomodoro"] + " min + " + options[i]["shortBreak"] + " min | " + options[i]["longBreak"] + " min",
                        i,
                        {}
                    )
                );
            }

            var modeDelegate = new ModeSelectDelegate();
            WatchUi.pushView(modeMenu, modeDelegate, WatchUi.SLIDE_DOWN);

        } else {
            var optionsMenu = new Menu2({ :title => "Options" });

            optionsMenu.addItem(
                new MenuItem(
                    "Edit modes",
                    "",
                    "editModes",
                    {}
                )
            );

            optionsMenu.addItem(
                new MenuItem(
                    "Vibrations",
                    vibrationModes[Application.Properties.getValue("vibrationStrength") % 25],
                    "vibrations",
                    {}
                )
            );

            optionsMenu.addItem(
                new ToggleMenuItem(
                    "DND during pomodoro",
                    "",
                    "dndMode",
                    true,
                    {}
                )
            );

            var optionsDelegate = new OptionsMenuDelegate();
            WatchUi.pushView(optionsMenu, optionsDelegate, WatchUi.SLIDE_UP);

        }

        return true;
    }

    function onKey(keyEvent as KeyEvent) as Boolean {
        switch (keyEvent.getKey()) {
            case KEY_ENTER:

                if (Application.Storage.getValue("isTimerInitialized") == false) {
                    Application.Storage.setValue("isTimerInitialized", true);
                }

                if (Application.Storage.getValue("isTimerStarted") == false) {
                    Application.Storage.setValue("timerEvent", true);

                    var vibeData = [new Attention.VibeProfile(Application.Properties.getValue("vibrationStrength"), 750)];

                    Attention.vibrate(vibeData);

                    WatchUi.requestUpdate();
                } else {

                    var resetMenu = new Menu2({:title => "Select option"});

                    resetMenu.addItem(
                        new MenuItem(
                            "Reset",
                            "",
                            "reset",
                            {}
                        )
                    );

                    resetMenu.addItem(
                        new MenuItem(
                            "Exit",
                            "",
                            "exit",
                            {}
                        )
                    );

                    var resetMenuDelegate = new ResetMenuDelegate();

                    WatchUi.pushView(resetMenu, resetMenuDelegate, WatchUi.SLIDE_DOWN);
                }

                break;
            default:
                break;
        }

        return true;
    }

}


class ResetMenuDelegate extends WatchUi.Menu2InputDelegate {

    var vibeData = [new Attention.VibeProfile(Application.Properties.getValue("vibrationStrength"), 1000)];

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        switch (item.getId()) {
            case "reset":

                Application.Storage.setValue("isTimerInitialized", false);
                Application.Storage.setValue("resetRequest", true);
                Application.Storage.setValue("timerEvent", false);
                Application.Storage.setValue("isTimerStarted", false);

                Attention.vibrate(vibeData);

                WatchUi.popView(WatchUi.SLIDE_UP);

                break;
        }
    }

}


// Mode menu delegate

class ModeSelectDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        Application.Storage.setValue("chosenMode", item.getId());
        WatchUi.requestUpdate();
        WatchUi.popView(WatchUi.SLIDE_UP);
    }

}




// Options menu delegate

class OptionsMenuDelegate extends WatchUi.Menu2InputDelegate {

    var vibrationModes = ["Off", "Mild", "Normal", "High", "Strong"];

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        switch (item.getId()) {
            case "editModes":
                handleEditModes();
                break;
            case "vibrations":
                handleVibrationsMenu(item);
            default:
                break;
        }
    }

    // Menu handlers

    function handleEditModes() {
        var editModesMenu = new Menu2({ :title => "Select mode to edit" });

        var options = Application.Storage.getValue("modes") as Array;

        for (var i = 0; i < options.size(); i++) {
                editModesMenu.addItem(
                new MenuItem(
                    options[i]["label"],
                    options[i]["group"] + "x " + options[i]["pomodoro"] + " min + " + options[i]["shortBreak"] + " min | " + options[i]["longBreak"] + " min",
                    i,
                    {}
                )
            );
        }

        var modeDelegate = new EditModesMenuDelegate();
        WatchUi.pushView(editModesMenu, modeDelegate, WatchUi.SLIDE_LEFT);
    }

    function handleVibrationsMenu(item) {
        var vibrationsMenu = new Menu2({:title => "Vibration strength"});

        for (var i = 0; i < vibrationModes.size(); i++) {
            vibrationsMenu.addItem(
                new MenuItem(
                    vibrationModes[i],
                    "",
                    i * 25, 
                    {}
                )
            );
        }

        var vibrationsDelegate = new VibrationsMenuDelegate(item);

        WatchUi.pushView(vibrationsMenu, vibrationsDelegate, WatchUi.SLIDE_LEFT);
    }

}

class VibrationsMenuDelegate extends WatchUi.Menu2InputDelegate {

    hidden var parentItem;

    function initialize(item) {
        Menu2InputDelegate.initialize();

        parentItem = item;
    }

    function onSelect(item as MenuItem) as Void {

        Application.Properties.setValue("vibrationStrength", item.getId());

        var vibeData = [new Attention.VibeProfile(item.getId() as Number, 750)];

        Attention.vibrate(vibeData);

    }

}

class EditModesMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var editMenu = new Menu2({ :title => "Edit values" });

        var modes = Application.Storage.getValue("modes") as Array;
        var itemId = item.getId();

        editMenu.addItem(
            new MenuItem(
                "Pomodoro",
                modes[itemId].get("pomodoro").toString() + " min",
                "pomodoro",
                {}
            )
        );

        editMenu.addItem(
            new MenuItem(
                "Short break",
                modes[itemId].get("shortBreak").toString() + " min",
                "shortBreak",
                {}
            )
        );

        editMenu.addItem(
            new MenuItem(
                "Long break",
                modes[itemId].get("longBreak").toString() + " min",
                "longBreak",
                {}
            )
        );

        editMenu.addItem(
            new MenuItem(
                "Pomodoros until long break",
                modes[itemId].get("group").toString(),
                "group",
                {}
            )
        );

        var modeDelegate = new EditMode(item);
        WatchUi.pushView(editMenu, modeDelegate, WatchUi.SLIDE_LEFT);
    }

}

class EditMode extends WatchUi.Menu2InputDelegate {

    hidden var parentItem;

    function initialize(item) {
        Menu2InputDelegate.initialize();

        parentItem = item;
    }

    function onSelect(item as MenuItem) as Void {

        WatchUi.pushView(new TimePicker(parentItem.getId(), item.getId(), item.getLabel()), new TimePickerDelegate(parentItem, item), WatchUi.SLIDE_LEFT);

    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}






















// Template delegate

class Test extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        return true;
    }

}