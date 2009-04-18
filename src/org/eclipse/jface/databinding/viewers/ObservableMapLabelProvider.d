/*******************************************************************************
 * Copyright (c) 2006, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 164247
 *     Brad Reynolds - bug 164134
 *******************************************************************************/

module org.eclipse.jface.databinding.viewers.ObservableMapLabelProvider;

import java.lang.all;

import java.util.Set;

import org.eclipse.core.databinding.observable.map.IMapChangeListener;
import org.eclipse.core.databinding.observable.map.IObservableMap;
import org.eclipse.core.databinding.observable.map.MapChangeEvent;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.viewers.ITableLabelProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.LabelProviderChangedEvent;
import org.eclipse.swt.graphics.Image;

/**
 * @since 1.1
 * 
 */
public class ObservableMapLabelProvider : LabelProvider
        , ILabelProvider, ITableLabelProvider {

    private final IObservableMap[] attributeMaps;

    private IMapChangeListener mapChangeListener;
    class MapChangeListener : IMapChangeListener {
        public void handleMapChange(MapChangeEvent event) {
            Set affectedElements = event.diff.getChangedKeys();
            LabelProviderChangedEvent newEvent = new LabelProviderChangedEvent(
                    this.outer, affectedElements
                            .toArray());
            fireLabelProviderChanged(newEvent);
        }
    };

    /**
     * @param attributeMap
     */
    public this(IObservableMap attributeMap) {
        this([ cast(IObservableMap)attributeMap ]);
    }

    /**
     * @param attributeMaps
     */
    public this(IObservableMap[] attributeMaps) {
mapChangeListener = new MapChangeListener();
        System.arraycopyT(attributeMaps, 0, this.attributeMaps = attributeMaps, 0, attributeMaps.length);
        for (int i = 0; i < attributeMaps.length; i++) {
            attributeMaps[i].addMapChangeListener(mapChangeListener);
        }
    }

    public void dispose() {
        for (int i = 0; i < attributeMaps.length; i++) {
            attributeMaps[i].removeMapChangeListener(mapChangeListener);
        }
        super.dispose();
    }

    public Image getImage(Object element) {
        return null;
    }

    public String getText(Object element) {
        return getColumnText(element, 0);
    }

    public Image getColumnImage(Object element, int columnIndex) {
        return null;
    }

    public String getColumnText(Object element, int columnIndex) {
        if (columnIndex < attributeMaps.length) {
            Object result = attributeMaps[columnIndex].get(element);
            return result is null ? "" : result.toString(); //$NON-NLS-1$
        }
        return null;
    }

}
