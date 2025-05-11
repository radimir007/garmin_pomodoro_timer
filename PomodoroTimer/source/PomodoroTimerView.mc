import Toybox.Graphics;
import Toybox.WatchUi;

class PomodoroTimerView extends WatchUi.View {

    hidden var currentMode, mainTimer, bottomText;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

        // Current mode element

        currentMode = new TextArea({
            :text          => "Work\n(25 min | 5 min + 30 min)",
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
            :text          => "25:00",
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
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {

    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        currentMode.draw(dc);
        mainTimer.draw(dc);
        bottomText.draw(dc);

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
