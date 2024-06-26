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
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Item {
    id: compactRoot

    //https://github.com/psifidotos/Latte-Dock/blob/891d6e4dfa59758f09dd4a61fb1ffcc888fd03f0/containment/package/contents/ui/main.qml#L747
    property bool isPanelEditMode: (!Plasmoid.immutable && Plasmoid.userConfiguring)
    property int minCompactLength: isPanelEditMode ? 0 : 1 // 0 means default
    readonly property int itemWidth: {
        // min is 1
        return Math.ceil(Math.max(rotator.implicitWidth, minCompactLength) + (dropdownButton.visible ? dropdownButton.implicitWidth + 5 : 0));
    }
    property var mouseIsInside: false

    Layout.preferredWidth: itemWidth
    Layout.minimumWidth: itemWidth

    MouseArea {
        id: mousearea

        function doDropdown() {
            mainlog("root.expanded = " + root.expanded);
            mainlog("Plasmoid.configuration : " + JSON.stringify(Plasmoid.configuration));
            mainlog("Plasmoid.immutable && Plasmoid.userConfiguring : " + Plasmoid.immutable + "  && " + Plasmoid.userConfiguring);
            if (!root.expanded) {
                root.expanded = true;
                root.kargosMenuOpen = true;
                mouseExitDelayer.stop();
            } else if (root.expanded) {
                root.expanded = false;
                root.kargosMenuOpen = false;
            }
        }

        hoverEnabled: true
        anchors.fill: parent
        onEntered: {
            mouseIsInside = true;
            mouseExitDelayer.stop();
        }
        onExited: {
            mouseExitDelayer.restart();
        }
        onClicked: {
            if (!rotator.mousearea.hasClickAction && root.dropdownItemsCount > 0)
                doDropdown();

        }
        Component.onCompleted: {
            // more compact
            rotator.mousearea.goButton.text = '';
            rotator.mousearea.runButton.text = '';
            rotator.mousearea.buttonsAlwaysVisible = true;
            rotator.mousearea.iconMode = true;
        }

        Timer {
            id: mouseExitDelayer

            interval: 1000
            onTriggered: {
                mouseIsInside = false;
            }
        }

        FirstLinesRotator {
            id: rotator

            buttonHidingDelay: true
            anchors.verticalCenter: parent.verticalCenter
            labelMaxWidth: Plasmoid.configuration.compactLabelMaxWidth
        }

        // Tooltip for arrow (taken from the systemtray plasmoid)
        Item {
            id: dropdownButton

            width: Kirigami.Units.iconSizes.smallMedium
            height: Kirigami.Units.iconSizes.smallMedium
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            visible: (root.dropdownItemsCount > 0) && (!Plasmoid.configuration.d_ArrowNeverVisible) && (mouseIsInside || root.expanded || Plasmoid.configuration.d_ArrowAlwaysVisible)

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: arrowMouseArea

                readonly property int arrowAnimationDuration: Kirigami.Units.shortDuration * 3

                anchors.fill: parent
                onClicked: {
                    mousearea.doDropdown();
                }

                KSvg.Svg {
                    id: arrowSvg

                    imagePath: "widgets/arrows"
                }

                KSvg.SvgItem {
                    id: arrow

                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height)
                    height: width
                    rotation: Plasmoid.expanded ? 180 : 0
                    opacity: Plasmoid.expanded ? 0 : 1
                    svg: arrowSvg
                    elementId: {
                        if (Plasmoid.location == PlasmaCore.Types.BottomEdge)
                            return "up-arrow";
                        else if (Plasmoid.location == PlasmaCore.Types.TopEdge)
                            return "down-arrow";
                        else if (Plasmoid.location == PlasmaCore.Types.LeftEdge)
                            return "right-arrow";
                        else
                            return "left-arrow";
                    }

                    Behavior on rotation {
                        RotationAnimation {
                            duration: arrowMouseArea.arrowAnimationDuration
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: arrowMouseArea.arrowAnimationDuration
                        }

                    }

                }

                KSvg.SvgItem {
                    anchors.centerIn: parent
                    width: arrow.width
                    height: arrow.height
                    rotation: Plasmoid.expanded ? 0 : -180
                    opacity: Plasmoid.expanded ? 1 : 0
                    svg: arrowSvg
                    elementId: {
                        if (Plasmoid.location == PlasmaCore.Types.BottomEdge)
                            return "down-arrow";
                        else if (Plasmoid.location == PlasmaCore.Types.TopEdge)
                            return "up-arrow";
                        else if (Plasmoid.location == PlasmaCore.Types.LeftEdge)
                            return "left-arrow";
                        else
                            return "right-arrow";
                    }

                    Behavior on rotation {
                        RotationAnimation {
                            duration: arrowMouseArea.arrowAnimationDuration
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: arrowMouseArea.arrowAnimationDuration
                        }

                    }

                }

            }

        }

    }

}
