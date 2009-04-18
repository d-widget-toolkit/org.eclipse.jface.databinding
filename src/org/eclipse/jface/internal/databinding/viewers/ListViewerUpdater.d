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

module org.eclipse.jface.internal.databinding.viewers.ListViewerUpdater;
import org.eclipse.jface.internal.databinding.viewers.ViewerUpdater;

import java.lang.all;

import org.eclipse.jface.viewers.AbstractListViewer;

/**
 * NON-API - A {@link ViewerUpdater} that updates {@link AbstractListViewer}
 * instances.
 * 
 * @since 1.2
 */
class ListViewerUpdater : ViewerUpdater {
    private AbstractListViewer viewer;

    this(AbstractListViewer viewer) {
        super(viewer);
        this.viewer = viewer;
    }

    public void insert(Object element, int position) {
        viewer.insert(element, position);
    }

    public void remove(Object element, int position) {
        viewer.remove(element);
    }

    public void add(Object[] elements) {
        viewer.add(elements);
    }

    public void remove(Object[] elements) {
        viewer.remove(elements);
    }
}
