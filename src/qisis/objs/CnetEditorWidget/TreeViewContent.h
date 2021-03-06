#ifndef TreeViewContent_H
#define TreeViewContent_H


// parent
#include <QAbstractScrollArea>


class QEvent;
class QKeyEvent;
template< typename T > class QList;
class QMouseEvent;
class QPoint;
class QResizeEvent;


namespace Isis {
  namespace CnetViz {
    class AbstractTreeItem;
    class TreeView;
    class AbstractTreeModel;

    /**
     * @author ????-??-?? Unknown
     *
     * @internal
     *   @history 2012-09-28 Kimberly Oyama - Changed member variables to be prefixed with "m_".
     */
    class TreeViewContent : public QAbstractScrollArea {
        Q_OBJECT

      public:
        TreeViewContent(QWidget *parent);
        virtual ~TreeViewContent();
        QSize minimumSizeHint() const;
        QSize sizeHint() const;
        AbstractTreeModel *getModel();
        void setModel(AbstractTreeModel *someModel);


      signals:
        void treeSelectionChanged();
        void treeSelectionChanged(QList< AbstractTreeItem * >);


      public slots:
        void refresh();


      protected:
        bool eventFilter(QObject *target, QEvent *event);
        void keyPressEvent(QKeyEvent *event);
        void leaveEvent(QEvent *event);
        void mouseDoubleClickEvent(QMouseEvent *event);
        void mouseMoveEvent(QMouseEvent *event);
        void mousePressEvent(QMouseEvent *event);
        void mouseReleaseEvent(QMouseEvent *event);
        void paintEvent(QPaintEvent *event);
        void resizeEvent(QResizeEvent *event);
        void scrollContentsBy(int dx, int dy);


      private:
        TreeViewContent(const TreeViewContent &other);
        TreeViewContent &operator=(const TreeViewContent &other);


      private:
        void nullify();
        void paintItemText(QPainter *, int, QPoint, QPoint);
        void drawCollapsedArrow(QPainter *, QRect);
        void drawExpandedArrow(QPainter *, QRect);
        QRect getArrowRect(AbstractTreeItem *item) const;


      private slots:
        void scrollTo(QList< AbstractTreeItem * >);
        void scrollTo(AbstractTreeItem *);
        void setAlternatingRowColors(bool);
        void updateItemList();


      private:
        TreeView *m_parentView;
        AbstractTreeModel *m_model;
        QList< AbstractTreeItem * > * m_items;

        //! The bool is true if the arrow in the item was pressed
        QPair< AbstractTreeItem *, bool > * m_pressedItem;

        //! The bool is true if the mouse is hovering over the arrow
        QPair< AbstractTreeItem *, bool > * m_hoveredItem;

        AbstractTreeItem *m_lastDirectlySelectedItem;
        QList<AbstractTreeItem *> * m_lastShiftSelection;

        QPoint *m_mousePressPos;
        int m_rowHeight;
        int m_contentWidth;
        bool m_alternatingRowColors;


      private:
        static const int ITEM_PADDING = 4;
        static const int ITEM_INDENTATION = 23;
    };
  }
}

#endif
