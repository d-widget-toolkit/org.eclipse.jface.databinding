/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matthew Hall - bug 223123
 *******************************************************************************/
module org.eclipse.jface.internal.databinding.provisional.viewers.ViewerLabelProvider;

import java.lang.all;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.eclipse.core.databinding.util.Policy;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.viewers.ILabelProviderListener;
import org.eclipse.jface.viewers.IViewerLabelProvider;
import org.eclipse.jface.viewers.LabelProviderChangedEvent;
import org.eclipse.jface.viewers.ViewerLabel;
import org.eclipse.swt.graphics.Image;

/**
 * NON-API - Generic viewer label provider.
 * @since 1.1
 *
 */
public class ViewerLabelProvider : IViewerLabelProvider,
        ILabelProvider {

    private List listeners;

    this(){
        listeners = new ArrayList();
    }

    /**
     * Subclasses should override this method. They should not call the base
     * class implementation.
     */
    public void updateLabel(ViewerLabel label, Object element) {
        label.setText(element.toString());
    }

    protected final void fireChangeEvent(Collection changes) {
        final LabelProviderChangedEvent event = new LabelProviderChangedEvent(
                this, changes.toArray());
        ILabelProviderListener[] listenerArray = arraycast!(ILabelProviderListener)( listeners
                .toArray());
        for (int i = 0; i < listenerArray.length; i++) {
            ILabelProviderListener listener = listenerArray[i];
            try {
                listener.labelProviderChanged(event);
            } catch (Exception e) {
                Policy.getLog().log(
                        new Status(IStatus.ERROR, Policy.JFACE_DATABINDING, e
                                .msg, e));
            }
        }
    }

    public final Image getImage(Object element) {
        ViewerLabel label = new ViewerLabel("", null); //$NON-NLS-1$
        updateLabel(label, element);
        return label.getImage();
    }

    public final String getText(Object element) {
        ViewerLabel label = new ViewerLabel("", null); //$NON-NLS-1$
        updateLabel(label, element);
        return label.getText();
    }

    public void addListener(ILabelProviderListener listener) {
        listeners.add(cast(Object)listener);
    }

    public void dispose() {
        listeners.clear();
    }

    public final bool isLabelProperty(Object element, String property) {
        return true;
    }

    public void removeListener(ILabelProviderListener listener) {
        listeners.remove(cast(Object)listener);
    }

}
