/**
 * @file
 * $Revision: 1.19 $
 * $Date: 2010/03/22 19:44:53 $
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
#include "OpenRecentProjectWorkOrder.h"

#include <QCoreApplication>
#include <QDebug>
#include <QMessageBox>

#include "FileName.h"
#include "Project.h"

namespace Isis {

/**
 * @brief Constructor which creates a WorkOrder that will open a recent project.
 * @param project The Project that this work order should be interacting with
 *
 */
  OpenRecentProjectWorkOrder::OpenRecentProjectWorkOrder(Project *project) :
  WorkOrder(project) {
    QAction::setText(tr("Open &Recent Project") );
    setCreatesCleanState(true);
  }


  /**
   * @brief Copies the OpenRecentProjectWorkOrder 'other' into this new instance.
   * @param other The WorkOrder being copied.
   *
   */
  OpenRecentProjectWorkOrder::OpenRecentProjectWorkOrder(const OpenRecentProjectWorkOrder &other) :
      WorkOrder(other) {
  }


  /**
   * @brief The Destructor.
   */
  OpenRecentProjectWorkOrder::~OpenRecentProjectWorkOrder() {

  }


  /**
   * @brief Returns a copy of this OpenRecentProjectWorkOrder instance.
   * @return @b ( OpenRecentWorkOrder *) A pointer to a copy of this object.
   */
  OpenRecentProjectWorkOrder *OpenRecentProjectWorkOrder::clone() const {
    return new OpenRecentProjectWorkOrder(*this);
  }


  /**
   * @brief This function determines if the given project file name can be opened.
   * @param projectFileName  The path to the project file.
   * @return @b bool True if the file exists, False otherwise.
   */
  bool OpenRecentProjectWorkOrder::isExecutable(QString projectFileName) {
    FileName fname = projectFileName;
    if (!fname.fileExists() )
      return false;

    return true;
  }


  /**
   * @brief Attempts to open the recent project.
   * @return  @b bool True if successful, False if not.
   */
  bool OpenRecentProjectWorkOrder::execute() {
    bool success = WorkOrder::execute();

    // We dislike the progress bar
    // delete progressBar();

    // If more than this work order is in the history, don't allow this operation
    if (success && project()->workOrderHistory().count()) {
      QMessageBox::critical(NULL, tr("Unable To Open a Project"),
                            tr("If you have modified your current project, you cannot open a new "
                               "project because this is not yet implemented"));
      success = false;
    }
    else if (success) {
      QString projectName = QAction::text();

      if (!projectName.isEmpty() ) {
        project()->open(projectName);
      }
      else {
        success = false;
      }
    }

    return success;
  }
}
