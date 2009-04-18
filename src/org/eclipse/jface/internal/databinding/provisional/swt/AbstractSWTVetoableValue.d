/*******************************************************************************
 * Copyright (c) 2006 The Pampered Chef, Inc. and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     The Pampered Chef, Inc. - initial API and implementation
 ******************************************************************************/

module org.eclipse.jface.internal.databinding.provisional.swt.AbstractSWTVetoableValue;

import java.lang.all;

import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.value.AbstractVetoableValue;
import org.eclipse.jface.databinding.swt.ISWTObservableValue;
import org.eclipse.jface.databinding.swt.SWTObservables;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.core.databinding.observable.value.IValueChangeListener;

/**
 * NON-API - An abstract superclass for vetoable values that gurantees that the 
 * observable will be disposed when the control to which it is attached is
 * disposed.
 * 
 * @since 1.1
 */
public abstract class AbstractSWTVetoableValue : AbstractVetoableValue , ISWTObservableValue {
    public override Object getValue(){
        return super.getValue();
    }
    public override void setValue( Object v ){
        super.setValue(v);
    }
    public void addValueChangeListener(IValueChangeListener listener) {
        super.addValueChangeListener(listener);
    }
    public void removeValueChangeListener(IValueChangeListener listener) {
        super.removeValueChangeListener(listener);
    }

    private final Widget widget;

    /**
     * Standard constructor for an SWT VetoableValue.  Makes sure that
     * the observable gets disposed when the SWT widget is disposed.
     * 
     * @param widget
     */
    protected this(Widget widget) {
        this(SWTObservables.getRealm(widget.getDisplay()), widget);
    }
    
    /**
     * Constructs a new instance for the provided <code>realm</code> and <code>widget</code>.
     * 
     * @param realm
     * @param widget
     * @since 1.2
     */
    protected this(Realm realm, Widget widget) {
disposeListener = new _DisposeListener();
        super(realm);
        this.widget = widget;
        if (widget is null) {
            throw new IllegalArgumentException("The widget parameter is null."); //$NON-NLS-1$
        }
        widget.addDisposeListener(disposeListener);
    }
    
    private DisposeListener disposeListener;
    class _DisposeListener : DisposeListener {
        public void widgetDisposed(DisposeEvent e) {
            this.outer.dispose();
        }
    };

    /**
     * @return Returns the widget.
     */
    public Widget getWidget() {
        return widget;
    }
}
