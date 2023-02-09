import QtQuick 2.7
import QtQuick.Layouts 1.1
//import QtGraphicalEffects 1.15
import QtMultimedia 5.15
import "Lists"
import "utils.js" as Utils

FocusScope {

	FontLoader { id: generalFont; source: "assets/fonts/font.ttf" }

	property var settings: {
        return {
            background:         	api.memory.has("Background") ? "assets/background/xmb-wave-" + api.memory.get("Background") + ".jpg" : "assets/background/xmb-wave-1.jpg",
            iconSource:             api.memory.has("Icon Source") ? api.memory.get("Icon Source") : "0",
			videoBackground:		api.memory.has("Video Background") ? api.memory.get("Video Background") : "0",
			hourClock:				api.memory.has("12/24 Hour Clock") ? api.memory.get("12/24 Hour Clock") : "0",
			language:				api.memory.has("Language") ? api.memory.get("Language") : "0",
			batteryPerc:			api.memory.has("Battery Percentage Indicator") ? api.memory.get("Battery Percentage Indicator") : "0"
        }
    }
	
	// Background
    Item {
    id: background
        
        anchors.fill: parent

        property string bgImage1
        property string bgImage2
        property bool firstBG: true
        
        //property var bgData: itemBar.currentItem
        property var bgSource: {if (collectionBar.currentCollection.idx == -3 ) { settings.background } else if (itemBar.currentItem != null) return itemBar.currentItem.assets.background} //collectionBar.currentCollection.idx > -2 ? bgData.background : (collectionBar.currentCollection.background) //(bgData ? Utils.fanArt(bgData) || bgData.assets.screenshots[0] : "") : (collectionBar.currentCollection.background)
        onBgSourceChanged: { if (bgSource != "") swapImage(bgSource) }

        states: [
            State { // this will fade in gameBG2 and fade out gameBG1
                name: "fadeInRect2"
                PropertyChanges { target: gameBG1; opacity: 0}
                PropertyChanges { target: gameBG2; opacity: 1}
            },
            State   { // this will fade in gameBG1 and fade out gameBG2
                name:"fadeOutRect2"
                PropertyChanges { target: gameBG1; opacity: 1}
                PropertyChanges { target: gameBG2; opacity: 0}
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { property: "opacity"; easing.type: Easing.InOutQuad; duration: 300  }
            }
        ]

        function swapImage(newSource) {
            if (firstBG) {
                // Go to second image
                if (newSource)
                    bgImage2 = newSource

                firstBG = false
                } else {
                // Go to first image
                if (newSource)
                    bgImage1 = newSource

                firstBG = true
            }
            background.state = background.state == "fadeInRect2" ? "fadeOutRect2" : "fadeInRect2"
        }

        Image {
        id: gameBG1

            anchors.fill: parent
            source: background.bgImage1
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(parent.width, parent.height)
            smooth: true
            asynchronous: true
            //visible: collectionAxis.currentIndex >= 2
        }

        Image {
        id: gameBG2

            anchors.fill: parent
            source: background.bgImage2
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(parent.width, parent.height)
            smooth: true
            asynchronous: true
            //visible: collectionAxis.currentIndex >= 2
        }
		
		


	visible: { if (collectionBar.currentCollection.idx == -3){
		if (settings.videoBackground == 1) {visible: true}
		else { if (settings.videoBackground == 0) {visible: false}
		}
	}
	else if (itemBar.focus == false) {visible: true}
	else if (settings.videoBackground == 0) {visible: false}
	else { if(settings.videoBackground == 1) {visible: true}
		}
	}
    }
	
	Item {
			Video {
			id: videobg
			x: 0
			y: 0
			width: 1920
			height: 1080
			source: "assets/video/psp.mp4"
			autoPlay: true
			loops: MediaPlayer.Infinite
		}
		visible: { if (collectionBar.currentCollection.idx == -3){
			if (settings.videoBackground == 0){
				if (itemBar.focus == false) {visible: true}
				}
			else { if(settings.videoBackground == 1){
				if (itemBar.focus == false) {visible: false}
				}
			}
		}
		else if (itemBar.focus == false) {visible: false}
		else if (settings.videoBackground == 0) {visible: true}
		 else {
		if (settings.videoBackground == 1) {visible: false}
			}
		}
	}
		        
	Item {			
			Image {
			id: blurBG
            source: "assets/background/blurbg.png"
            x: 0
			y: 0
			width: 1920
			height: 1080
            opacity: 0.9
			visible: { if (collectionBar.currentCollection.idx == -3) {visible: true}
			else if	(itemBar.focus == false) {visible: false}
			else { if (itemBar.focus == true) {visible: true}
			}
        }
	}
			Image {
			id: blurBG2
			source: "assets/background/blurbg2.png"
			x: 0
			y: 0
			width: 1920
			height: 1080
			opacity: 0.9
			visible: { if (collectionBar.currentCollection.idx == -3) {visible: false}
			else if	(itemBar.focus == true) {visible: false}
			else { if (itemBar.focus == false) {visible: true}
			}
		}
	}
}
	
	Text {
		id: currentCategory
		
		anchors {
            left: parent.left; leftMargin: vpx(40)
            //right: parent.right
			top: parent.top; topMargin: vpx(28)
			//bottom: parent.bottom
        }
		// will become a number between 0-19
		text: collectionBar.currentCollection != null ? collectionBar.currentCollection.name : ""
		//z:10
		
		color: "white"
		font.family: generalFont.name
		font.pointSize: 22
	}
	
	Text {
        id: sysTime

       function set() { if (settings.hourClock == 0) {
            sysTime.text = Qt.formatDateTime(new Date(), "d/MM h:mm AP")
        } else {
			if (settings.hourClock == 1) {
			sysTime.text = Qt.formatDateTime(new Date(), "d/MM hh:mm")
			}
		}
	}

			anchors.right: parent.right 
			anchors.rightMargin: { if (settings.batteryPerc == 1) {return vpx(120)}
			else { if (settings.batteryPerc == 0) {return vpx(180)}
				}
			}
            anchors.top: parent.top
			anchors.topMargin: vpx(28)

		
	
		
        Timer {
            id: textTimer
            interval: 1000 // Run the timer every second
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: sysTime.set()
        }
		
		color: "white"
		font.family: generalFont.name
		font.pointSize: 22
    }
	
	Text {
		id: batteryPercentage
		text: api.device.batteryPercent.toFixed(2)*100 +"%"
		anchors {
			right: parent.right; rightMargin: vpx(110)
			top: parent.top; topMargin: vpx(28)
			}
		color: "white"
		font.family: generalFont.name
		font.pointSize: 22
		visible: { if (settings.batteryPerc == 0) {return true}
		else { if (settings.batteryPerc == 1) {return false}
			}
		}
	}
		
	//battery
	Item {
    // border
    Rectangle {
        id: batteryBorder;
		x: 1790
		y: 53
        height: 38;
        width: 61;
        radius: 1.5;
        color: 'transparent';
		border.color: "white";
        border.width: 3;
        
    }

		
    // fill 1
    Rectangle {
		id: fill1
        color: white;
		x: 1797
		y: 59
        width: 13
        height: 25
        radius: 1.1
		visible: if (api.device.batteryPercent*100 > 66)
		{visible: true}
		else
		{visible: false}		
        }
		
	// fill 2
	 Rectangle {
        color: white;
		x: 1814
		y: 59
        width: 13
        height: 25
        radius: 1.1
		visible: if (api.device.batteryPercent*100 > 33)
		{visible: true}
		else
		{visible: false}
        }
	
	// fill 3
	 Rectangle {
		x: 1831
		y: 59
		width: 13
		height: 25
		radius: 1.1
		color: if (api.device.batteryPercent*100 > 15)
		{color: "white"}
		else
		{color: "red"}
		}
		
	// nub
		Rectangle {
		color: white;
		x: 1784
		y: 65
		width: 8
		height: 14
		radius: 1.5
		
		}
    
    // button
    Rectangle {
        height: parent.height * .42;
        width: parent.height * .14;
        radius: width;
        color: white;
		}
		

	
}

	CollectionBar {
		id: collectionBar
		anchors {
            left: parent.left
            right: parent.right
			top: parent.top; topMargin: vpx(156)
			//bottom: parent.bottom
        }
		
		active: itemBar.focus
		onCollectionChanged: {
		 if (collectionBar.currentCollection != null) itemBar.update(collectionBar.currentCollection.idx)
			
		}
	}
	
	ItemBar {
		id: itemBar
		anchors {
            left: parent.left//; leftMargin: vpx(320)
            //right: parent.right
			top: parent.top
			bottom: parent.bottom
        }
		focus: true //!gameDetails.focus //true
		collectionIdx: { if (collectionBar.currentCollection != null) return collectionBar.currentCollection.idx }
		
		//onSettings: {
		//	focus = false;
		//}
	}
	
	GameDetails {
		id: gameDetails
		//opacity: focus ? 1.0 : 0.0
		anchors {
            left: parent.left; leftMargin: vpx(250)
            right: parent.right; rightMargin: vpx(75)
			top: parent.top//; topMargin: vpx(75)
			bottom: parent.bottom//; bottomMargin: vpx(75)
        }
		focus: !itemBar.focus
		
		currentGame: itemBar.currentItem
		collectionIdx: { if (collectionBar.currentCollection != null) return collectionBar.currentCollection.idx }
		
		onExit: {
			itemBar.focus = true;
		}
	}
	
	Keys.onPressed: {                    
			// Details
		if (api.keys.isDetails(event) && !event.isAutoRepeat) {
			event.accepted = true;
			itemBar.focus ? itemBar.focus = false : itemBar.focus = true
			navSfx.play()
		}
		if (api.keys.isNextPage(event)) {
			event.accepted = true;
			collectionBar.list.incrementCurrentIndex();
		}
		if (api.keys.isPrevPage(event)) {
			event.accepted = true;
			collectionBar.list.decrementCurrentIndex();
		}
	}
	
	SoundEffect {
        id: navSfx
        source: "assets/audio/nav.wav"
        volume: 1
    }
	SoundEffect {
        id: backSfx
        source: "assets/audio/back.wav"
        volume: 1
    }
}
