import "../vendor/FontAwesome"
/*
*
* kargos
*
* Copyright (C) 2017 - 2020 Daniel Glez-Peña
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program. If not, see
* <http://www.gnu.org/licenses/gpl-3.0.html>.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Row {
    id: control

    property bool buttonHidingDelay: false
    property var kargosObject
    property var rotatingItems: []
    property var currentMessage: -1
    property int labelMaxWidth: 0
    readonly property alias icon: icon
    readonly property alias image: image
    readonly property alias label: label
    readonly property alias mousearea: mousearea

    function getCurrentItem() {
        mainlog("log currentMessage" + currentMessage);
        mainlog("log rotatingItems" + JSON.stringify(rotatingItems));
        return (rotatingItems.length > 0 && currentMessage != -1) ? rotatingItems[currentMessage] : null;
    }

    function updateItems() {
        image.update();
        label.update();
        icon.update();
        mousearea.reset();
    }

    function update(stdout) {
        var newItems = [];
        kargosObject = parseItems(stdout);
        kargosObject.titleItem.forEach(function(parsedItem) {
            newItems.push(parsedItem);
        });
        kargosObject.bodyItems.forEach(function(parsedItem) {
            if (parsedItem.dropdown !== undefined && parsedItem.dropdown === 'false')
                newItems.push(parsedItem);

        });
        if (newItems.length == 0)
            currentMessage = -1;
        else if (currentMessage >= newItems.length)
            currentMessage = 0;
        else if (currentMessage === -1)
            currentMessage = 0;
        rotatingItems = newItems;
        mainlog("log rotatingItems = " + JSON.stringify(rotatingItems));
        if (root.command == '')
            label.text = 'No command configured. Go to settings...';
        else
            updateItems();
    }

    function rotateNext() {
        if (control.rotatingItems.length > 0) {
            control.currentMessage = (control.currentMessage + 1) % control.rotatingItems.length;
            updateItems();
        }
    }

    function rotatePrev() {
        if (control.rotatingItems.length > 0) {
            control.currentMessage = control.currentMessage - 1;
            if (control.currentMessage == -1)
                control.currentMessage = control.rotatingItems.length - 1;

            updateItems();
        }
    }

    spacing: 2
    anchors.left: parent.left
    anchors.right: parent.right
    height: label.implicitHeight + 20

    Kirigami.Icon {
        id: icon

        function update() {
            var item = getCurrentItem();
            if (item !== null && item !== undefined)
                source = (item.iconName !== undefined) ? item.iconName : null;

            if (source === null)
                visible = false;
            else
                visible = true;
            iconMouseArea.cursorShape = root.isClickable(item) ? Qt.PointingHandCursor : Qt.ArrowCursor;
        }

        visible: false
        source: 'dialog-ok'
        anchors.verticalCenter: control.verticalCenter
        height: control.height * 0.75

        MouseArea {
            id: iconMouseArea

            anchors.fill: parent
            onClicked: {
                var item = getCurrentItem();
                root.doItemClick(item);
            }
        }

    }

    Image {
        id: image

        function update() {
            var item = getCurrentItem();
            if (item !== null && item !== undefined) {
                if (item.image !== undefined)
                    createImageFile(item.image, function(filename) {
                    image.source = filename;
                });

                if (item.imageURL !== undefined)
                    image.source = item.imageURL;

                if (item.imageWidth !== undefined)
                    image.sourceSize.width = item.imageWidth;

                if (item.imageHeight !== undefined)
                    image.sourceSize.height = item.imageHeight;

                // clear image
                if (item.imageURL === undefined && item.image === undefined)
                    image.source = '';

                imageMouseArea.cursorShape = root.isClickable(item) ? Qt.PointingHandCursor : Qt.ArrowCursor;
            }
        }

        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: control.verticalCenter
        height: control.height * 0.6
        Component.onCompleted: {
            sourceSize.height = control.height;
        }

        MouseArea {
            id: imageMouseArea

            anchors.fill: parent
            onClicked: {
                var item = getCurrentItem();
                root.doItemClick(item);
            }
        }

    }

    Item {
        id: labelAndButtons

        readonly property bool labelTooSmall: label.implicitWidth < mousearea.runButton.implicitWidth + mousearea.goButton.implicitWidth + 10

        implicitWidth: label.width + (mousearea.goButton.visible ? mousearea.goButton.implicitWidth + 5 : 0) + (mousearea.runButton.visible ? mousearea.runButton.implicitWidth + 5 : 0)
        implicitHeight: label.implicitHeight
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: label

            property var item
            property var defaultFontFamily
            property var defaultFontSize
            property var defaultColor

            function update() {
                item = getCurrentItem();
                mainlog("log getCurrentItem" + JSON.stringify(item));
                if (item !== null && item !== undefined) {
                    if (item["kargos.fa_icon"])
                        text = FontAwesome[item["kargos.fa_icon"]] + " " + item.title;
                    else
                        text = item.title;
                    if (item.font !== undefined)
                        font.family = item.font;
                    else
                        font.family = defaultFontFamily;
                    if (item.size !== undefined)
                        font.pointSize = item.size;
                    else
                        font.pointSize = defaultFontSize;
                    if (item.color !== undefined)
                        color = item.color;
                    else
                        color = label.defaultColor;
                } else {
                    text = 'starting nothing...';
                }
                mousearea.item = item;
                var _correctedMaxWidth = label.implicitWidth;
            }

            text: 'starting...'
            textFormat: Text.RichText
            anchors.verticalCenter: parent.verticalCenter
            elide: (labelMaxWidth > 0) ? Text.ElideRight : Text.ElideNone
            width: (labelMaxWidth > 0) ? labelMaxWidth : label.implicitWidth
            Component.onCompleted: {
                defaultFontFamily = font.family;
                defaultFontSize = font.pointSize;
                defaultColor = color + ''; //append '' to avoid binding to color property, we want just to intialize it.
                update();
                if (Plasmoid.configuration.rotation > 0)
                    rotationTimer.running = true;

            }

            PlasmaCore.ToolTipArea {
                anchors.fill: parent
                mainText: (control.kargosObject) ? control.kargosObject.tooltipmaintitle : ""
                enabled: (control.kargosObject) ? control.kargosObject.tooltipmaintitle : false
            }

        }

        ItemTextMouseArea {
            id: mousearea

            buttonHidingDelay: control.buttonHidingDelay
            onEntered: {
                rotationTimer.running = false;
            }
            onExited: {
                if (Plasmoid.configuration.rotation > 0)
                    rotationTimer.running = true;

            }
            onWheel: {
                if (wheel.angleDelta.y < 0) {
                    if (item.wheelDown !== undefined)
                        root.doItemWheelDown(item);
                    else
                        rotateNext();
                } else if (wheel.angleDelta.y > 0) {
                    if (item.wheelUp !== undefined)
                        root.doItemWheelUp(item);
                    else
                        rotatePrev();
                }
            }
        }

    }

    Connections {
        function onExited(sourceName, stdout) {
            control.update(stdout);
        }

        target: commandResultsDS
    }

    Timer {
        id: rotationTimer

        interval: Plasmoid.configuration.rotation * 1000
        running: false
        repeat: true
        onTriggered: {
            rotateNext();
        }
    }

}
