import QtQuick 2.0

// Credit to this awesome lad
// Copyright (c) Aurélien Gâteau and contributors.
// https://agateau.com/2016/reordering-a-listview-via-dragndrop-1/
// https://github.com/agateau

Item {
    id: root
    default property Item contentItem
    // This item will become the parent of the dragged item during the drag operation
    property Item draggedItemParent
    signal moveItemRequested(int from, int to)
    width: contentItem.width
    height: contentItem.height
    // Make contentItem a child of contentItemWrapper
    onContentItemChanged: {
        contentItem.parent = contentItemWrapper;
    }

    Rectangle {
        id: contentItemWrapper
        anchors.fill: parent
        //
        color: "transparent"
        Drag.active: ((model.index + 1) === listModel.count) ? false : dragArea.drag.active
        Drag.hotSpot {
            x: contentItem.width / 2
            y: contentItem.height / 2
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: parent
            // Keep the dragged item at the same X position. Nice for lists, but not mandatory
            drag.axis: Drag.YAxis
            // Disable smoothed so that the Item pixel from where we started the drag remains
            // under the mouse cursor
            drag.smoothed: false
            onReleased: {
                if (drag.active) {
                    emitMoveItemRequested();
                }
            }
        }
    }

    states: [
        State {
            when: dragArea.drag.active
            name: "dragging"
            ParentChange {
                target: contentItemWrapper
                parent: draggedItemParent
            }
            PropertyChanges {
                target: contentItemWrapper
                opacity: 0.9
                anchors.fill: undefined
                width: contentItem.width
                height: contentItem.height
            }
            PropertyChanges {
                target: root
                height: 0
            }
        }
    ]

    Loader {
        id: topDropAreaLoader
        active: model.index === 0
        anchors {
            left: parent.left
            right: parent.right
            bottom: root.verticalCenter
        }
        height: contentItem.height
        sourceComponent: Component {
            DraggableItemDropArea {
                dropIndex: 0
            }
        }
    }
    DraggableItemDropArea {
        anchors {
            left: parent.left
            right: parent.right
            top: root.verticalCenter
        }
        height: contentItem.height
        dropIndex: model.index + 1
    }
    function emitMoveItemRequested()
    {
        var dropArea = contentItemWrapper.Drag.target;
        if (!dropArea) {
            return;
        }
        var dropIndex = dropArea.dropIndex;
        // If the target item is below us, then decrement dropIndex because the target item is
        // going to move up when our item leaves its place
        if (model.index < dropIndex) {
            dropIndex--;
        }
        if (model.index === dropIndex || (dropIndex + 1) === listModel.count) {
            return;
        }

        root.moveItemRequested(model.index, dropIndex);
    }
}
