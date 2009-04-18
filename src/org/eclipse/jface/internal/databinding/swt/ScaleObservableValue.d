/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Peter Centgraf - bug 175763
 *******************************************************************************/
module org.eclipse.jface.internal.databinding.swt.ScaleObservableValue;
import org.eclipse.jface.internal.databinding.swt.SWTProperties;

import java.lang.all;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.internal.databinding.provisional.swt.AbstractSWTObservableValue;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.widgets.Scale;

/**
 * @since 1.0
 * 
 */
public class ScaleObservableValue : AbstractSWTObservableValue {

    private final Scale scale;

    private final String attribute;

    private bool updating = false;

    private int currentSelection;
    
    private SelectionListener listener;

    /**
     * @param scale
     * @param attribute
     */
    public this(Scale scale, String attribute) {
        super(scale);
        this.scale = scale;
        this.attribute = attribute;
        init();
    }
    
    /**
     * @param realm
     * @param scale
     * @param attribute
     */
    public this(Realm realm, Scale scale, String attribute) {
        super(realm, scale);
        this.scale = scale;
        this.attribute = attribute;
        init();
    }
    
    private void init() {       
        if (attribute.equals(SWTProperties.SELECTION)) {
            currentSelection = scale.getSelection();
            scale.addSelectionListener(listener = new class() SelectionAdapter {
                public void widgetSelected(SelectionEvent e) {
                    if (!updating) {
                        int newSelection = this.outer.scale
                        .getSelection();
                        notifyIfChanged(currentSelection, newSelection);
                        currentSelection = newSelection;
                    }
                }
            });
        } else if (!attribute.equals(SWTProperties.MIN)
                && !attribute.equals(SWTProperties.MAX)) {
            throw new IllegalArgumentException(
                    "Attribute name not valid: " ~ attribute); //$NON-NLS-1$
        }
    }

    public void doSetValue(Object value) {
        int oldValue;
        int newValue;
        try {
            updating = true;
            newValue = (cast(Integer) value).intValue();
            if (attribute.equals(SWTProperties.SELECTION)) {
                oldValue = scale.getSelection();
                scale.setSelection(newValue);
                currentSelection = newValue;
            } else if (attribute.equals(SWTProperties.MIN)) {
                oldValue = scale.getMinimum();
                scale.setMinimum(newValue);
            } else if (attribute.equals(SWTProperties.MAX)) {
                oldValue = scale.getMaximum();
                scale.setMaximum(newValue);
            } else {
                Assert.isTrue(false, "invalid attribute name:" ~ attribute); //$NON-NLS-1$
                return;
            }
            
            notifyIfChanged(oldValue, newValue);
        } finally {
            updating = false;
        }
    }

    public Object doGetValue() {
        int value = 0;
        if (attribute.equals(SWTProperties.SELECTION)) {
            value = scale.getSelection();
        } else if (attribute.equals(SWTProperties.MIN)) {
            value = scale.getMinimum();
        } else if (attribute.equals(SWTProperties.MAX)) {
            value = scale.getMaximum();
        }
        return new Integer(value);
    }

    public Object getValueType() {
        return Integer.TYPE;
    }

    /**
     * @return attribute being observed
     */
    public String getAttribute() {
        return attribute;
    }
    
    /* (non-Javadoc)
     * @see org.eclipse.core.databinding.observable.value.AbstractObservableValue#dispose()
     */
    public synchronized void dispose() {
        super.dispose();
        
        if (listener !is null && !scale.isDisposed()) {
            scale.removeSelectionListener(listener);
        }
        listener = null;
    }
    
    private void notifyIfChanged(int oldValue, int newValue) {
        if (oldValue !is newValue) {
            fireValueChange(Diffs.createValueDiff(new Integer(oldValue),
                    new Integer(newValue)));
        }
    }
}
