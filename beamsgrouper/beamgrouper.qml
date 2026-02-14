import QtQuick 2.9
import MuseScore 3.0
import "selectionhelper.js" as SelHelper

MuseScore {
    menuPath: "Plugins.Beams Grouper"
    description: "Groups the beams of the selection"
    version: "1.0"
    onRun: {
        // 1) getSelection
        var chords = SelHelper.getChordsRestsFromCursor(curScore);

        if (chords && (chords.length > 0)) {
            console.log("CHORDS FOUND FROM CURSOR");
        } else {
            chords = SelHelper.getChordsRestsFromSelection(curScore);
            if (chords && (chords.length > 0)) {
                console.log("CHORDS FOUND FROM SELECTION");
            }
        }

        // 2) répartir les chords par voice
        var all = SelHelper.copySelection(chords);

        var elements = all.filter(function (e) {
            return (e._element.type === Element.CHORD || e._element.type === Element.REST);
        });
        
        console.log("=> "+elements.length+" elements");

        var voices = {};
        for (var c = 0; c < elements.length; c++) {
            var e = elements[c];
            var t = e.track;
            var cc = voices[t];

            if (typeof cc === "undefined") {
                cc = [];
                voices[t] = cc;
            }

            cc.push(e);
        }

        // 3) par voice, trier les chords par segments
        var tracks = Object.keys(voices);
        console.log("=> on "+tracks.length+" voices ("+tracks+")");
        
        
        for (t = 0; t < tracks.length; t++) {
            var vv = voices[tracks[t]];
            vv = vv.sort(function (a, b) {
                return a.tick - b.tick;
            });
            voices[tracks[t]] = vv;

        }

        // 4) mettre les beams
        for (t = 0; t < tracks.length; t++) {
            var vv = voices[tracks[t]];
            console.log("Dealing with voice :"+tracks[t]);
            if (vv.length==1) {
                  vv[0]._element.beamMode=4; // NONE
            } else {
                  vv[0]._element.beamMode = 1; // BEGIN
                  for (var c = 1; c < (vv.length-1); c++) {
                      vv[c]._element.beamMode = 2; // MID
                  }
                  vv[vv.length-1]._element.beamMode = 3; // END
            }
        }
    }

    function logThis(text) {
        console.log(text);
    }
}