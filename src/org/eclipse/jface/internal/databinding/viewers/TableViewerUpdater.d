/*******************************************************************************
 * Copyright (c) 2008 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 215531)
 *     Matthew Hall - bug 226765
 ******************************************************************************/

module org.eclipse.jface.internal.databinding.viewers.TableViewerUpdater;
import org.eclipse.jface.internal.databinding.viewers.ViewerUpdater;

import java.lang.all;

import org.eclipse.jface.viewers.AbstractTableViewer;

/**
 * NON-API - A {@link ViewerUpdater} that updates {@link AbstractTableViewer}
 * instances.
 * 
 * @since 1.2
 */
class TableViewerUpdater : ViewerUpdater {
    private AbstractTableViewer viewer;

    this(AbstractTableViewer viewer) {
        super(viewer);
        this.viewer = viewer;
    }

    public void insert(Object element, int position) {
        viewer.insert(element, position);
    }

    public void remove(Object element, int position) {
        viewer.remove(element);
    }

    public void replace(Object oldElement, Object newElement, int position) {
        if (viewer.getComparator() is null && viewer.getFilters().length is 0)
            viewer.replace(newElement, position);
        else {
            super.replace(oldElement, newElement, position);
        }
    }

    public void add(Object[] elements) {
        viewer.add(elements);
    }

    public void remove(Object[] elements) {
        viewer.remove(elements);
    }
}
