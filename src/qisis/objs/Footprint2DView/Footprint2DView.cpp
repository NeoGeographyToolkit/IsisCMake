/**
 * @file
 * $Date$
 * $Revision$
 *
 *   Unless noted otherwise, the portions of Isis written by the USGS are
 *   public domain. See individual third-party library and package descriptions
 *   for intellectual property information, user agreements, and related
 *   information.
 *
 *   Although Isis has been used by the USGS, no warranty, expressed or
 *   implied, is made by the USGS as to the accuracy and functioning of such
 *   software and related material nor shall the fact of distribution
 *   constitute any such warranty, and no responsibility is assumed by the
 *   USGS in connection therewith.
 *
 *   For additional information, launch
 *   $ISISROOT/doc//documents/Disclaimers/Disclaimers.html
 *   in a browser or see the Privacy &amp; Disclaimers page on the Isis website,
 *   http://isis.astrogeology.usgs.gov, and the USGS privacy and disclaimers on
 *   http://www.usgs.gov/privacy.html.
 */
#include "IsisDebug.h"

#include "Footprint2DView.h"

#include <QAction>
#include <QDragEnterEvent>
#include <QDragMoveEvent>
#include <QDropEvent>
#include <QItemSelectionModel>
#include <QList>
#include <QSize>
#include <QSizePolicy>
#include <QToolBar>
#include <QVBoxLayout>
#include <QWidget>
#include <QWidgetAction>

#include "Image.h"
#include "MosaicGraphicsView.h"
#include "MosaicSceneWidget.h"
#include "ProjectItem.h"
#include "ProjectItemModel.h"
#include "ToolPad.h"

namespace Isis {
  /**
   * Constructor.
   * 
   * @param parent Pointer to parent QWidget
   */
  Footprint2DView::Footprint2DView(QWidget *parent) : AbstractProjectItemView(parent) {
    m_sceneWidget = new MosaicSceneWidget(NULL, true, false, NULL, this);
    m_sceneWidget->getScene()->installEventFilter(this);
    m_sceneWidget->setAcceptDrops(false);
    MosaicGraphicsView *graphicsView = m_sceneWidget->getView();
    graphicsView->installEventFilter(this);
    graphicsView->setAcceptDrops(false);

    connect( internalModel(), SIGNAL( itemAdded(ProjectItem *) ),
             this, SLOT( onItemAdded(ProjectItem *) ) );

    connect(m_sceneWidget, SIGNAL(queueSelectionChanged() ),
            this, SLOT(onQueueSelectionChanged() ) );

    QVBoxLayout *layout = new QVBoxLayout;
    setLayout(layout);

    layout->addWidget(m_sceneWidget);

    m_permToolBar = new QToolBar("Standard Tools", 0);
    m_permToolBar->setObjectName("permToolBar");
    m_permToolBar->setIconSize(QSize(22, 22));
    //toolBarLayout->addWidget(m_permToolBar);

    m_activeToolBar = new QToolBar("Active Tool", 0);
    m_activeToolBar->setObjectName("activeToolBar");
    m_activeToolBar->setIconSize(QSize(22, 22));
    //toolBarLayout->addWidget(m_activeToolBar);

    m_toolPad = new ToolPad("Tool Pad", 0);
    m_toolPad->setObjectName("toolPad");
    //toolBarLayout->addWidget(m_toolPad);
    

    m_sceneWidget->addToPermanent(m_permToolBar);
    m_sceneWidget->addTo(m_activeToolBar);
    m_sceneWidget->addTo(m_toolPad);
    
    m_activeToolBarAction = new QWidgetAction(this);
    m_activeToolBarAction->setDefaultWidget(m_activeToolBar);

    setAcceptDrops(true);

    QSizePolicy policy = sizePolicy();
    policy.setHorizontalPolicy(QSizePolicy::Expanding);
    policy.setVerticalPolicy(QSizePolicy::Expanding);
    setSizePolicy(policy);

  }


  /**
   * Destructor
   */
  Footprint2DView::~Footprint2DView() {
    delete m_permToolBar;
    delete m_activeToolBar;
    delete m_toolPad;

    m_permToolBar = 0;
    m_activeToolBar = 0;
    m_toolPad = 0;
  }


  /**
   * Returns the suggested size for the widget.
   *
   * @return @b QSize The size
   */
  QSize Footprint2DView::sizeHint() const {
    return QSize(800, 600);
  }


  /**
   * Event filter to filter out drag and drop events. 
   *
   * @param[in] watched (QObject *) The object being filtered
   * @param[in] event (QEvent *) The event
   *
   * @return @b bool True if the event was intercepted
   */
  bool Footprint2DView::eventFilter(QObject *watched, QEvent *event) {
    if (event->type() == QEvent::DragEnter) {
      dragEnterEvent( static_cast<QDragEnterEvent *>(event) );
      return true;
    }
    else if (event->type() == QEvent::DragMove) {
      dragMoveEvent( static_cast<QDragMoveEvent *>(event) );
      return true;
    }
    else if (event->type() == QEvent::Drop) {
      dropEvent( static_cast<QDropEvent *>(event) );
      return true;
    }

    return AbstractProjectItemView::eventFilter(watched, event);
  }


  /**
   * Slot to connect to the itemAdded signal from the model. If the
   * item is an image it adds it to the scene.
   *
   * @param[in] item (ProjectItem *) The item
   */
  void Footprint2DView::onItemAdded(ProjectItem *item) {
    if (!item) {
      return;
    }

    if (item->isImage()) {

      ImageList images;
      images.append(item->image());

      m_sceneWidget->addImages(images);
      
      if ( !m_imageItemMap.value( item->image() ) ) {
        m_imageItemMap.insert( item->image(), item);
      }
    }
  }


  /**
   * Slot to connect to the queueSelectionChanged signal from a
   * MosiacSceneWidget. Updates the selection in the model.
   */
  void Footprint2DView::onQueueSelectionChanged() {
    ImageList selectedImages = m_sceneWidget->selectedImages();

    if (selectedImages.isEmpty() ) {
      return;
    }

    Image *currentImage = selectedImages.first();

    internalModel()->selectionModel()->clear();

    if ( ProjectItem *item = m_imageItemMap.value(currentImage) ) {
      internalModel()->selectionModel()->setCurrentIndex(item->index(), QItemSelectionModel::Select); 
    }


    foreach (Image *image, selectedImages) {
      if ( ProjectItem *item = m_imageItemMap.value(image) ) {
        internalModel()->selectionModel()->select(item->index(), QItemSelectionModel::Select); 
      }
    }
  }


  /**
   * Returns a list of actions for the permanent tool bar.
   *
   * @return @b QList<QAction*> The actions
   */
  QList<QAction *> Footprint2DView::permToolBarActions() {
    return m_permToolBar->actions();
  }

  
  /**
   * Returns a list of actions for the active tool bar.
   *
   * @return @b QList<QAction*> The actions
   */
  QList<QAction *> Footprint2DView::activeToolBarActions() {
    QList<QAction *> actions;
    actions.append(m_activeToolBarAction);
    return actions;
  }
  
  
  /**
   * Returns a list of actions for the tool pad.
   *
   * @return @b QList<QAction*> The actions
   */
  QList<QAction *> Footprint2DView::toolPadActions() {
    return m_toolPad->actions();
  }


}
