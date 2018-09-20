//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;

// This implements an analog watch face
// Original design by Austen Harbour
class AnalogView extends Ui.WatchFace
{
    var font;
    var isAwake;
    var screenShape;
    var dndIcon;
    var frIcon;

    function initialize() {
        WatchFace.initialize();
        screenShape = Sys.getDeviceSettings().screenShape;
    }

    function onLayout(dc) {
        font = Ui.loadResource(Rez.Fonts.id_font_black_diamond);
        if (Sys.getDeviceSettings() has :doNotDisturb) {
            dndIcon = Ui.loadResource(Rez.Drawables.DoNotDisturbIcon);
        } else {
            dndIcon = null;
        }
        frIcon = Ui.loadResource(Rez.Drawables.FreeRickIcon);
    }

    // Draw the watch hand
    // @param dc Device Context to Draw
    // @param angle Angle to draw the watch hand
    // @param length Length of the watch hand
    // @param width Width of the watch hand
    function drawHand(dc, angle, length, width) {
        // Map out the coordinates of the watch hand
        var coords = [[-(width / 2),0], [-(width / 2), -length], [width / 2, -length], [width / 2, 0]];
        var result = new [4];
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i += 1) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [centerX + x, centerY + y];
        }

        // Draw the polygon
        dc.fillPolygon(result);
        dc.fillPolygon(result);
    }

    // Handle the update event
    function onUpdate(dc) {
        var width;
        var height;
        var screenWidth = dc.getWidth();
        var clockTime = Sys.getClockTime();
        var hourHand;
        var hourTail;
        var minuteHand;
        var minuteTail;
        var secondHand;
        var secondTail;

        width = dc.getWidth();
        height = dc.getHeight();

        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);

        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);

        // Clear the screen
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

        // Draw the gray rectangle
        //dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
        //dc.fillPolygon([[0, 0], [dc.getWidth(), 0], [dc.getWidth(), dc.getHeight()], [0, 0]]);

        // Draw the numbers
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        
        // Draw the do-not-disturb icon
        if (null != dndIcon && Sys.getDeviceSettings().doNotDisturb) {
            dc.drawBitmap( width / 2 - 15, height * 0.75, dndIcon);
        }
        
        // Draw the free rick icon
        if (null != frIcon) {
            dc.drawBitmap( 0, 0, frIcon);
        }

        // Draw the time
        dc.drawText(60, 52, Gfx.FONT_TINY, clockTime.hour/10, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(60, 75, Gfx.FONT_TINY, clockTime.hour%10, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(60, 97, Gfx.FONT_TINY, ":", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(60, 120, Gfx.FONT_TINY, clockTime.min/10, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(60, 142, Gfx.FONT_TINY, clockTime.min%10, Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw the date
        dc.drawText(165, 52, Gfx.FONT_TINY, info.day_of_week.substring(0,1), Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(165, 75, Gfx.FONT_TINY, info.day_of_week.substring(1,2), Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(165, 97, Gfx.FONT_TINY, info.day_of_week.substring(2,3), Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(165, 120, Gfx.FONT_TINY, info.day/10, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(165, 142, Gfx.FONT_TINY, info.day%10, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function onEnterSleep() {
        isAwake = false;
        Ui.requestUpdate();
    }

    function onExitSleep() {
        isAwake = true;
    }
}
