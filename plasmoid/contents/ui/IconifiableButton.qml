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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program.  If not, see
 * <http://www.gnu.org/licenses/gpl-3.0.html>.
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore

Item {
    id: control

    property string text: ''
    property string iconName: ''
    property bool iconMode: true

    signal clicked()

    width: iconMode ? controlInnerIcon.implicitWidth : controlInnerButton.implicitWidth
    height: iconMode ? controlInnerIcon.implicitHeight : controlInnerButton.implicitHeight
    implicitWidth: iconMode ? controlInnerIcon.implicitWidth : controlInnerButton.implicitWidth
    implicitHeight: iconMode ? controlInnerIcon.implicitHeight : controlInnerButton.implicitHeight

    Button {
        id: controlInnerButton

        visible: !control.iconMode
        ToolTip.text: control.text
        icon.name: control.iconName
        anchors.fill: parent
        onClicked: control.clicked()
    }

    Kirigami.Icon {
        id: controlInnerIcon

        visible: control.iconMode
        source: control.iconName
        //anchors.fill: parent
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        width: controlInnerIcon.implicitWidth * 0.95

        // opacity: 0.5
        MouseArea {
            /*hoverEnabled: true

                onEntered: {
                    controlInnerIcon.opacity = 1.0
                }

                onExited: {
                    controlInnerIcon.opacity = 0.5
                }*/

            anchors.fill: parent
            onClicked: control.clicked()
        }

    }

}
