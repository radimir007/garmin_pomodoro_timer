import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PomodoroTimerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();

        if (Application.Storage.getValue("modes") == null) {
            var options = [
                {
                    "label" => "Study",
                    "shortBreak" => 5,
                    "longBreak" => 30,
                    "pomodoro" => 30,
                    "group" => 2
                },
                {
                    "label" => "Work",
                    "shortBreak" => 10,
                    "longBreak" => 30,
                    "pomodoro" => 25,
                    "group" => 3
                }
            ];

            Application.Storage.setValue("modes", options);
        }

        Application.Storage.setValue("isTimerInitialized", false);
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new PomodoroTimerView(), new PomodoroTimerDelegate() ];
    }

}

function getApp() as PomodoroTimerApp {
    return Application.getApp() as PomodoroTimerApp;
}