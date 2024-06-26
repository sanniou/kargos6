import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras

ConfigPage {
    id: page

    property alias cfg_width: width.value
    property alias cfg_compactLabelMaxWidth: compactLabelMaxWidth.value
    property alias cfg_height: height.value
    property alias cfg_d_ArrowNeverVisible: d_ArrowNeverVisible.checked
    property alias cfg_d_ArrowAlwaysVisible: d_ArrowAlwaysVisible.checked
    property alias cfg_d_ArrowVisibleAsNeeded: d_ArrowVisibleAsNeeded.checked

    ConfigSection {
        label: i18n("Preferred width in px")

        SpinBox {
            id: width

            Layout.fillWidth: true
            to: 10000
        }

    }

    ConfigSection {
        label: i18n("Preferred height in px")

        SpinBox {
            id: height

            Layout.fillWidth: true
            to: 10000
        }

    }

    ConfigSection {
        label: i18n("Compact (on panel) fixed text width (0: unlimited)")

        SpinBox {
            id: compactLabelMaxWidth

            Layout.fillWidth: true
            to: 10000
        }

    }

    ConfigSection {
        GroupBox {
            // Layout.columnSpan: 2

            title: i18n('Dropdown arrow visible option: ')
            anchors.left: parent.left

            ColumnLayout {
                // ExclusiveGroup { id: dropdownArrowVisibleGroup }
                RadioButton {
                    id: d_ArrowAlwaysVisible

                    text: i18n('Always visible')
                    autoExclusive: true
                }

                RadioButton {
                    id: d_ArrowVisibleAsNeeded

                    text: i18n('Visible as needed')
                    autoExclusive: true
                }

                RadioButton {
                    id: d_ArrowNeverVisible

                    text: i18n('Never visible')
                    autoExclusive: true
                }

            }

        }

    }

}
