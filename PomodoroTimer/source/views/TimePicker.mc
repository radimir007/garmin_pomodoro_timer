import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;

class TimePicker extends WatchUi.View {

    hidden var minutes, inc, dec, upperText, bottomText;

    hidden var parentModeId, parentItemId, parentLabel;

    function initialize(modeId, itemId, label) {
        View.initialize();

        parentModeId = modeId;
        parentItemId = itemId;
        parentLabel = label;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

        inc = new Text({
            :text           => "+",
            :font           => Graphics.FONT_NUMBER_MEDIUM,
            :color          => Graphics.COLOR_WHITE,
            :locX           => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY           => 0,
            :justification  => Graphics.TEXT_JUSTIFY_CENTER
        });

        dec = new Text({
            :text           => "-",
            :font           => Graphics.FONT_NUMBER_HOT,
            :color          => Graphics.COLOR_WHITE,
            :locX           => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY           => dc.getHeight() - 120,
            :justification  => Graphics.TEXT_JUSTIFY_CENTER
        });

        bottomText = new Text({
            :text           => "Press ENTER to continue",
            :font           => Graphics.FONT_XTINY,
            :color          => Graphics.COLOR_GREEN,
            :locX           => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY           => dc.getHeight() - dc.getHeight() / 3 + 10,
            :justification  => Graphics.TEXT_JUSTIFY_CENTER
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

        var modes = Application.Storage.getValue("modes");

        upperText = new Text({
            :text           => parentLabel + ":",
            :font           => Graphics.FONT_XTINY,
            :color          => Graphics.COLOR_DK_GRAY,
            :locX           => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY           => dc.getHeight() / 4,
            :justification  => Graphics.TEXT_JUSTIFY_CENTER
        });

        var additionalText = "";

        if (!parentItemId.equals("group")) {
            additionalText = " min";
        }

        minutes = new Text({
            :text           => modes[parentModeId][parentItemId].toString() + additionalText,
            :font           => Graphics.FONT_LARGE,
            :color          => Graphics.COLOR_WHITE,
            :locX           => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY           => WatchUi.LAYOUT_VALIGN_CENTER,
            :justification  => Graphics.TEXT_JUSTIFY_CENTER
        });

        minutes.draw(dc);
        inc.draw(dc);
        dec.draw(dc);
        upperText.draw(dc);
        bottomText.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
