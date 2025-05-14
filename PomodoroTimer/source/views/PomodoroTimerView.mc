import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Timer;

class PomodoroTimerView extends WatchUi.View {

    hidden var currentMode, mainTimer, bottomText;
    hidden var currentTime, currentStageText;

    var timer = new Timer.Timer();
    var readinessTimer = new Timer.Timer();
    var isCircleVisible = true;
    var breakState = false;

    var vibeData = [new Attention.VibeProfile(Application.Properties.getValue("vibrationStrength"), 750)];

    var flow = ["pomodoro", "shortBreak", "longBreak"];
    var groupsCount;
    var pomodoroCounter = 1;

    function initialize() {
        View.initialize();
        if (Application.Storage.getValue("chosenMode") == null) {
            Application.Storage.setValue("chosenMode", 0);
        }

        Application.Storage.setValue("isTimerStarted", false);
        Application.Storage.setValue("timerEvent", false);

        var chosenModeId = Application.Storage.getValue("chosenMode");
        var mode = Application.Storage.getValue("modes")[chosenModeId];

        groupsCount = mode["group"];

        System.println(groupsCount);

        Application.Storage.setValue("currentTimerStage", 0);
        Application.Storage.setValue("currentPomodoroGroup", 1);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

        var chosenModeId = Application.Storage.getValue("chosenMode");
        var mode = Application.Storage.getValue("modes")[chosenModeId];

        // Current mode element

        currentMode = new TextArea({
            :text          => mode["label"] + "\n" + mode["group"] + "x " + mode["pomodoro"] +                  "min + " + mode["shortBreak"] + " min | " + mode["longBreak"] + " min",
            :font          => Graphics.FONT_XTINY,
            :locX          => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY          => 0 + 40,
            :width         => dc.getWidth(),
            :height        => 90,
            :color         => Graphics.COLOR_LT_GRAY,
            :justification => Graphics.TEXT_JUSTIFY_CENTER 
        });

        // Main timer element

        mainTimer = new Text({
            :text          => mode["pomodoro"] + ":00",
            :font          => Graphics.FONT_NUMBER_HOT,
            :locX          => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY          => WatchUi.LAYOUT_VALIGN_CENTER,
            :color         => Graphics.COLOR_WHITE,
            :justification => Graphics.TEXT_JUSTIFY_CENTER 
        });

        bottomText = new Text({
            :text          => "Tap for options!",
            :font          => Graphics.FONT_XTINY,
            :locX          => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY          => dc.getHeight() - dc.getHeight() / 4,
            :color         => Graphics.COLOR_GREEN,
            :justification => Graphics.TEXT_JUSTIFY_CENTER 
        });

        currentTime = new Text({
            :text          => "",
            :font          => Graphics.FONT_TINY,
            :locX          => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY          => dc.getHeight() - 60,
            :color         => Graphics.COLOR_LT_GRAY,
            :justification => Graphics.TEXT_JUSTIFY_CENTER 
        });

        currentStageText = new Text({
            :text          => "Current: Pomodoro",
            :font          => Graphics.FONT_XTINY,
            :locX          => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY          => dc.getHeight() / 2 + 75,
            :color         => Graphics.COLOR_LT_GRAY,
            :justification => Graphics.TEXT_JUSTIFY_CENTER 
        });
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {

    }

    var timerValue;

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var isTimerInitialized = Application.Storage.getValue("isTimerInitialized");

        var chosenModeId = Application.Storage.getValue("chosenMode");
        var mode = Application.Storage.getValue("modes")[chosenModeId];

        var currentStage = Application.Storage.getValue("currentTimerStage");
        var currentGroup = Application.Storage.getValue("currentPomodoroGroup");

        if (Application.Storage.getValue("timerEvent") == true) {

            if (Application.Storage.getValue("isTimerStarted") == false) {
                timerValue = mode[flow[currentStage]] * 60;
                timer.start(method(:timerCallback), 300, true);

                Application.Storage.setValue("timerEvent", false);
                Application.Storage.setValue("isTimerStarted", true);

            }           
        }

        if (Application.Storage.getValue("isTimerStarted") == false) {
            timerValue = mode[flow[currentStage]] * 60;
            var seconds = (timerValue % 60 < 10 ? "0" : "") + (timerValue % 60).toString();
            var minutes = (timerValue / 60).toString();
            mainTimer.setText(minutes + ":" + seconds);

            
            if (breakState == false) {
                readinessTimer.start(method(:blinkCircle), 1000, true);
                breakState = true;
            }

            if (isCircleVisible == true) {
                dc.setPenWidth(3);
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(dc.getWidth() / 2, dc.getHeight() / 2, dc.getWidth() / 2);
            }

            
        }

        if (Application.Storage.getValue("resetRequest") == true) {
            Application.Storage.setValue("currentPomodoroGroup", 1);
            Application.Storage.setValue("currentTimerStage", 0);

            pomodoroCounter = 1;
            timer.stop();

            isCircleVisible = true;
            breakState = false;

            Application.Storage.deleteValue("resetRequest");

            mainTimer.setColor(Graphics.COLOR_WHITE);
        }

        if (Application.Storage.getValue("isTimerInitialized") == false) {
            currentMode.setText(mode["label"] + "\n" + mode["group"] + "x " + mode["pomodoro"] + " min + " + mode["shortBreak"] + " min | " + mode["longBreak"] + " min");

            bottomText.draw(dc);

        } else {
            var currentModeText = "";

            var upperTime;
            var seconds;
            var minutes;

            switch (currentStage) {
                case 0:
                    if (currentGroup == groupsCount) {
                        upperTime = mode[flow[2]] * 60;
                        seconds = (upperTime % 60 < 10 ? "0" : "") + (upperTime % 60).toString();
                        minutes = (upperTime / 60).toString();

                        currentModeText = "Next: Long break (" + minutes + ":" + seconds + ")";
                    } else {
                        upperTime = mode[flow[1]] * 60;
                        seconds = (upperTime % 60 < 10 ? "0" : "") + (upperTime % 60).toString();
                        minutes = (upperTime / 60).toString();

                        currentModeText = "Next: Short break (" + minutes + ":" + seconds + ")";
                    }
                    
                    break;
                case 1:
                    upperTime = mode[flow[0]] * 60;
                    seconds = (upperTime % 60 < 10 ? "0" : "") + (upperTime % 60).toString();
                    minutes = (upperTime / 60).toString();

                    currentModeText = "Next: Pomodoro (" + minutes + ":" + seconds + ")";

                case 2:
                    upperTime = mode[flow[0]] * 60;
                    seconds = (upperTime % 60 < 10 ? "0" : "") + (upperTime % 60).toString();
                    minutes = (upperTime / 60).toString();

                    currentModeText = "Next: Pomodoro (" + minutes + ":" + seconds + ")";
                default:
                    break;
            }


            var myTime = System.getClockTime();
            currentTime.setText(myTime.hour.format("%02d") + ":" + myTime.min.format("%02d"));

            currentTime.draw(dc);

            var tempStageText = "";

            switch (currentStage) {
                case 0:
                    tempStageText = "Pomodoro";
                    currentStageText.setColor(Graphics.COLOR_ORANGE);
                    mainTimer.setColor(Graphics.COLOR_ORANGE);
                    break;
                case 1:
                    tempStageText = "Short break";
                    currentStageText.setColor(Graphics.COLOR_GREEN);
                    mainTimer.setColor(Graphics.COLOR_GREEN);
                    break;
                case 2:
                    tempStageText = "Long break";
                    currentStageText.setColor(Graphics.COLOR_GREEN);
                    mainTimer.setColor(Graphics.COLOR_GREEN);
                    break;
                default:
                    break;
            }

            currentStageText.setText("Current: " + tempStageText);
            currentStageText.draw(dc);

            currentMode.setText("Cycle: " + pomodoroCounter + "\n" + currentModeText);
            WatchUi.requestUpdate();
        }

        currentMode.draw(dc);
        mainTimer.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function timerCallback() as Void {

        var chosenModeId = Application.Storage.getValue("chosenMode");
        var mode = Application.Storage.getValue("modes")[chosenModeId];

        if (timerValue == 0) {

            updateTimerText();
            WatchUi.requestUpdate();

            // If timer 

            var currentStage = Application.Storage.getValue("currentTimerStage");            

            if (currentStage == 1) {
                var temp = Application.Storage.getValue("currentPomodoroGroup");
                temp += 1;
                Application.Storage.setValue("currentPomodoroGroup", temp);
                Application.Storage.setValue("currentTimerStage", 0);
                Application.Storage.setValue("isTimerStarted", false);

                Attention.vibrate(vibeData);

                timer.stop();
            
            } else if (currentStage == 2) {
                Application.Storage.setValue("currentPomodoroGroup", 1);
                Application.Storage.setValue("isTimerStarted", false);
                Application.Storage.setValue("currentTimerStage", 0);

                pomodoroCounter += 1;

                Attention.vibrate(vibeData);

                timer.stop();
            } else {

                if (Application.Storage.getValue("currentPomodoroGroup").equals(groupsCount)) {
                    Application.Storage.setValue("currentTimerStage", currentStage + 2);

                    Application.Storage.setValue("timerEvent", true);
                    Application.Storage.setValue("isTimerStarted", false);

                    Attention.vibrate(vibeData);

                    timerValue = mode["longBreak"] * 60;

                    updateTimerText();
                    WatchUi.requestUpdate();
                    
                } else {
                    Application.Storage.setValue("currentTimerStage", currentStage + 1);

                    timerValue = mode["shortBreak"] * 60;

                    updateTimerText();
                    WatchUi.requestUpdate();

                    Application.Storage.setValue("timerEvent", true);
                    Application.Storage.setValue("isTimerStarted", false);

                    Attention.vibrate(vibeData);
                }
                
            }

            WatchUi.requestUpdate();
        } else {
            timerValue -= 1;
            updateTimerText();
            WatchUi.requestUpdate();
        }

        
    }

    function updateTimerText() as Void {
        var seconds = (timerValue % 60 < 10 ? "0" : "") + (timerValue % 60).toString();
        var minutes = (timerValue / 60).toString();
        mainTimer.setText(minutes + ":" + seconds);
    }

    function blinkCircle() as Void {
        isCircleVisible = !isCircleVisible;
        WatchUi.requestUpdate();
    }

}
